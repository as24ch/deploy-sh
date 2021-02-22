prompt () {
  if [ "$1" == "" ]
    then
      echo "Prompt error: variable name not provided"
      exit -1
  fi

  current="${!1}"
  [[ "$2" == "--skip" || "$3" == "--skip" ]] && is_skippable="true"
  [[ "$2" == "--optional" || "$3" == "--optional" ]] && is_optional="true"
  
  [[ "$current" != "" && "$is_skippable" == "true" ]] && return
  [[ "$current" == "" && "$is_skippable" == "true" && "$is_optional" == "true" ]] && return

  echo -n "Provide $1"
  if [ "$current" == "" ]
    then 
      echo ": "
    else
      echo " (current=$current): "
  fi
  echo -n "=> "

  read input

  if [ "$input" == "" ]
    then
      if [[ "$current" == "" && "$is_optional" != "true" && $is_skippable != "true" ]]
        then
          prompt $1
        else
          input="$current"
      fi
  fi

  eval "export $1=$input"
}

propmt_config () {
  prompt GITHUB_TOKEN $1
  prompt GITHUB_REPOSITORY $1
  prompt GIT_CHECKOUT $1
  prompt SERVER_ENV $1
  prompt DEPLOY_DIR $1
  prompt WEBHOOK_URL $1 --optional
}

write_config () {
  echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"
export GITHUB_REPOSITORY=\"$GITHUB_REPOSITORY\"
export GIT_CHECKOUT=\"$GIT_CHECKOUT\"
export SERVER_ENV=\"$SERVER_ENV\"
export DEPLOY_DIR=\"$DEPLOY_DIR\"
export WEBHOOK_URL=\"$WEBHOOK_URL\"" > $(dirname $BASH_SOURCE[0])/config.sh
}

confirm () {
  echo "Please confirm [y/N]: "
  echo -n "=> "
  read input
  if [ "$input" == "y" ]
    then
      is_confirmed="true"
    else
      echo "
Live long and prosper!
      "
      exit 1
  fi
}

print_config () {
  echo "
Current deployment configuration:

GITHUB_TOKEN      = $GITHUB_TOKEN
GITHUB_REPOSITORY = $GITHUB_REPOSITORY
GIT_CHECKOUT      = $GIT_CHECKOUT
SERVER_ENV        = $SERVER_ENV
DEPLOY_DIR        = $DEPLOY_DIR
WEBHOOK_URL       = $WEBHOOK_URL
"
}

print_help () {
  echo "
* NodeJS application deployments scripts * 

- CLI - 

Usage: {script_name}.sh [arg=val...] [--flag]

Arguments (used to override existing configuration):

token    - overrides GITHUB_TOKEN
repo     - overrides GITHUB_REPOSITORY
checkout - overrides GIT_CHECKOUT
env      - overrides SERVER_ENV
dir      - overrides DEPLOY_DIR
           (should have respective access permitions)
webhook  - overrides WEBHOOK_URL

Flags:

--y      - Forces confirmation prompts
--info   - Prints current configuration
--help   - Prints help
--config - Starts interactive configuration update

- Config -

GITHUB_TOKEN      - Github token with repository read access
GITHUB_REPOSITORY - Github source code repository
GIT_CHECKOUT      - Git branch or tag with required code snapshot
SERVER_ENV        - Server environment. Usually one of: test, integration, staging, production
DEPLOY_DIR        - Location of the source file on server
WEBHOK_URL        - URL used for notifications during deployment process (Optional)

- Files -

cli.sh      - Interactive command line interface (Recommended)
prepare.sh  - Clones, installs dependencies and builds application in \"next\" folder of \"DEPLOY_DIR\"
rollout.sh  - Replaces \"next\" => \"app\" => \"prev\" folders in "DEPLOY_DIR" and runs \"start.sh\"
start.sh    - Starts / Re-starts application in \"app\" folder in \"DEPLOY_DIR\" using saved configuration
rollback.sh - Replaces \"prev\" => \"app\" => \"next\" folders in \"DEPLOY_DIR\" and runs \"start.sh\"
              Used for rapid revert of the last deployment
setup.sh    - Clean setup of deployments scripts
              Warning! Will remove previously configured applications
"
}

notify_webhook () {
  echo "$WEBHOOK_URL?server=$(hostname)&repo=$GITHUB_REPO&env=$SERVER_ENV&checkout=$GIT_CHECKOUT&step=$1"
}
