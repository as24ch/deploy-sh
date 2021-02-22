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

notify_webhook "rollback:run"

cd $DEPLOY_DIR

mv ./next ./del

notify_webhook "rollback:kill"

pm2 kill

mv ./app ./next

mv ./prev ./app

$dir/start.sh --slave

rm -rf ./del

mkdir ./prev

notify_webhook "rollback:done"

exit 0
