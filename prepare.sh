#!/bin/bash
set -e

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $dir/src/functions.sh

if [ "$1" != "--slave" ]
  then
    source $dir/src/config.sh
    source $dir/src/read_args.sh

    prompt GITHUB_REPOSITORY --skip
    prompt DEPLOY_DIR --skip
    prompt GIT_CHECKOUT --skip
fi
########################

notify prepare start

if [[ "$GIT_CHECKOUT" == "latest" ]]
  then
    export GIT_CHECKOUT=$(getLatestTag)
    export CURRENT_CHECKOUT=$(getCurrentCheckout)
    if [[ "$GIT_CHECKOUT" == "$CURRENT_CHECKOUT" ]]
      then
        notify deploy skipped
        exit 1
    fi
fi

cd $DEPLOY_DIR

rm -rf ./next

git clone $(getRepoUrl) $DEPLOY_DIR/next

cd ./next

git fetch --all --tags --prune

git checkout $GIT_CHECKOUT

npm install

npm run build

npm prune --production

notify prepare done

exit 0
