#!/bin/bash
set -e

action="deploy"

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source $dir/src/config.sh
source $dir/src/functions.sh
source $dir/src/read_args.sh

prompt_config --skip

if [ "$should_save_config" == "true" ]
  then
    write_config
    log "config saved"
fi

if [ "$is_confirmed" != "true" ]
  then
    echo "Will execute \"$action\" action with following configuration:"
    print_config
    confirm
fi

notify deploy start

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

notify deploy done

exit 0
