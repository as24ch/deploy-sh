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

notify start start

cd $DEPLOY_DIR/app

pm2 kill

sleep 1

pm2 start ./ecosystem.json --env $SERVER_ENV

notify start done

exit 0
