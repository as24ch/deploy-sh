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

prompt_config () {
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
export WEBHOOK_URL=\"$WEBHOOK_URL\"
" > $(dirname $BASH_SOURCE[0])/config.sh
}

confirm () {
  echo "Please confirm [y/N]: "
  echo -n "=> "
  read input
  if [ "$input" == "y" ]
    then
      is_confirmed="true"
    else
      echo "Live long and prosper!"
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

token    - Overrides GITHUB_TOKEN.
repo     - Overrides GITHUB_REPOSITORY.
checkout - Overrides GIT_CHECKOUT.
env      - Overrides SERVER_ENV.
dir      - Overrides DEPLOY_DIR.
           (folder provided must have respective access permitions)
webhook  - Overrides WEBHOOK_URL.
action   - Sets action to one of: deploy (default), prepare, rollout, start, rollback.
           Using this argument will have same effect as executing respective *.sh file.

Flags:

--y      - Forces confirmation prompts.
--info   - Prints current configuration.
--help   - Prints help.
--save   - Saves provided configuration.
--config - Starts interactive configuration update.

- Config -

GITHUB_TOKEN      - Github token with repository read access.
GITHUB_REPOSITORY - Github source code repository in format {user_name}/{repo_name}.
GIT_CHECKOUT      - Git branch or tag (supports \"latest\") with required code snapshot.
SERVER_ENV        - Server environment. Usually one of: test, integration, staging, production.
DEPLOY_DIR        - Location of the source file on server.
WEBHOK_URL        - (optional) URL used for notifications during deployment process.

- Files -

cli.sh      - (recommended) Interactive command line interface.
prepare.sh  - Clones, installs dependencies and builds application in \"next\" folder of \"DEPLOY_DIR\".
rollout.sh  - Replaces \"next\" => \"app\" => \"prev\" folders in "DEPLOY_DIR" and runs \"start.sh\".
start.sh    - Starts / Re-starts application in \"app\" folder in \"DEPLOY_DIR\" using saved configuration.
rollback.sh - Replaces \"prev\" => \"app\" => \"next\" folders in \"DEPLOY_DIR\" and runs \"start.sh\".
              Used for rapid revert of the last deployment.
setup.sh    - Clean setup of deployment scripts.
              Warning! Will remove previously configured applications.
"
}

log () {
  echo "***
*** $1
***"
}

notify () {
  log "[$2] $1"

  if [ "$WEBHOOK_URL" != "" ]
    then
      curl "$WEBHOOK_URL?server=$(hostname)&repo=$GITHUB_REPOSITORY&env=$SERVER_ENV&checkout=$GIT_CHECKOUT&action=$1&status=$2"
  fi
}
