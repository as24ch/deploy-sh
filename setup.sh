#!/bin/bash

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $dir/src/functions.sh
source $dir/src/read_args.sh

echo "
Hi there!
This script is going to prefrom a clean setup of deployments scripts for NodeJS applications on this machine.
"
if [ "$is_confirmed" != "true" ]
  then
    echo "Do you wan to continue?
    "
    confirm
    prompt_config
  else
    prompt_config --skip
fi

write_config

pm2 kill

chmod +x $dir/prepare.sh
chmod +x $dir/rollout.sh
chmod +x $dir/start.sh
chmod +x $dir/rollback.sh

rm -rf $DEPLOY_DIR
mkdir $DEPLOY_DIR

mkdir $DEPLOY_DIR/next
mkdir $DEPLOY_DIR/app
mkdir $DEPLOY_DIR/prev

echo "

All done.
Happy coding!
  
"
