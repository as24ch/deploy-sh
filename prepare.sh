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

cd $DEPLOY_DIR

rm -rf ./next

git clone https://$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git $DEPLOY_DIR/next

cd ./next

git fetch --all --tags --prune

[[ "$GIT_CHECKOUT" == "latest" ]] && GIT_CHECKOUT=$(git describe --tags `git rev-list --tags --max-count=1`)

git checkout $GIT_CHECKOUT

npm install

npm run build

npm prune --production

notify prepare done

exit 0
