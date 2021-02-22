#!/bin/bash
set -e

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $dir/src/functions.sh

if [ "$1" != "--slave" ]
  then
    source $dir/src/config.sh

    prompt DEPLOY_DIR --skip
    prompt SERVER_ENV --skip
fi

########################

notify_webhook "rollout:run"

cd $DEPLOY_DIR

mv ./prev ./del

notify_webhook "rollout:kill"

pm2 kill

mv ./app ./prev

mv ./next ./app

echo "ROLLOUT $dir"

$dir/start.sh --slave

rm -rf ./del

mkdir ./next

notify_webhook "rollout:done"

exit 0
