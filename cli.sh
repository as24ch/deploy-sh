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

case "$action" in
  prepare)
    $dir/prepare.sh --slave
    ;;
  rollout)
    $dir/rollout.sh --slave
    ;;
  start)
    $dir/start.sh --slave
    ;;
  deploy)
    $dir/prepare.sh --slave && $dir/rollout.sh --slave && notify deploy done
    ;;
  rollback)
    $dir/rollback.sh --slave
    ;;
esac

exit 0
