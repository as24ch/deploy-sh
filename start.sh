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

notify_webhook "start:run"

cd $DEPLOY_DIR

pm2 kill

sleep 1

notify_webhook "start:launch"

pm2 start ./app/ecosystem.json --env $SERVER_ENV

notify_webhook "start:done"

exit 0