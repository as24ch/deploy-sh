#!/bin/bash

dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $dir/src/functions.sh

echo "
Hi there!
This script is going to prefrom a clean setup of deployments scripts for NodeJS applications on this machine.

Do you wan to continue?
"

confirm

propmt_config
write_config

pm2 kill

chmod +x $dir/prepare.sh
chmod +x $dir/rollout.sh
chmod +x $dir/start.sh
chmod +x $dir/rollback.sh

sudo rm -rf $DEPLOY_DIR
sudo mkdir $DEPLOY_DIR
sudo chmod a+rwx $DEPLOY_DIR

mkdir $DEPLOY_DIR/next
mkdir $DEPLOY_DIR/app
mkdir $DEPLOY_DIR/prev

echo "

All done.
Happy coding!
  
"