#!/bin/bash
set -e

action="deploy"

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source $dir/src/config.sh
source $dir/src/functions.sh
source $dir/src/read_args.sh

propmt_config --skip

if [ "$is_confirmed" == "" ]
  then
    echo "
Will execute \"$action\" action with following configuration:"
    print_config
    confirm
fi

notify_webhook "deploy:run"

if [ "$action" == "prepare" ]
  then
    $dir/prepare.sh --slave
fi

if [ "$action" == "rollout" ]
  then
    $dir/rollout.sh --slave
fi

if [ "$action" == "start" ]
  then
    $dir/start.sh --slave
fi

if [ "$action" == "deploy" ]
  then
    $dir/prepare.sh --slave
    $dir/rollout.sh --slave
fi

if [ "$action" == "rollback" ]
  then
    $dir/rollback.sh --slave
fi

notify_webhook "deploy:done"

exit 0
