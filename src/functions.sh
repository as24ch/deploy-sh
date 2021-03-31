log () {
  echo "
***
*** $1
***
"
}

getRepoUrl () {
  echo "https://$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
}

getLatestTag () {
  echo $(git ls-remote --tags --refs --sort="v:refname" $(getRepoUrl) | tail -n1 | sed 's/.*\///')
}

getCurrentCheckout () {
  echo $(git -C $DEPLOY_DIR/app symbolic-ref -q --short HEAD || git -C $DEPLOY_DIR/app describe --tags --exact-match)
}

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
  prompt WEBHOOK $1 --optional
  prompt WEBHOOK_SHIPPED $1 --optional
  prompt WEBHOOK_DEPLOYED $1 --optional
  prompt WEBHOOK_RELEASED $1 --optional
}

write_config () {
  echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"
export GITHUB_REPOSITORY=\"$GITHUB_REPOSITORY\"
export GIT_CHECKOUT=\"$GIT_CHECKOUT\"
export SERVER_ENV=\"$SERVER_ENV\"
export DEPLOY_DIR=\"$DEPLOY_DIR\"
export WEBHOOK=\"$WEBHOOK\"
export WEBHOOK_SHIPPED=\"$WEBHOOK_SHIPPED\"
export WEBHOOK_DEPLOYED=\"$WEBHOOK_DEPLOYED\"
export WEBHOOK_RELEASED=\"$WEBHOOK_RELEASED\"
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

DEPLOY_DIR        = $DEPLOY_DIR
SERVER_ENV        = $SERVER_ENV
GIT_CHECKOUT      = $GIT_CHECKOUT
GITHUB_TOKEN      = $GITHUB_TOKEN
GITHUB_REPOSITORY = $GITHUB_REPOSITORY
WEBHOOK           = $WEBHOOK
WEBHOOK_SHIPPED   = $WEBHOOK_SHIPPED
WEBHOOK_DEPLOYED  = $WEBHOOK_DEPLOYED
WEBHOOK_RELEASED  = $WEBHOOK_RELEASED
"
}

print_help () {
  echo "
* NodeJS application deployments scripts *

- CLI -

Usage: {script_name}.sh [arg=val...] [--flag]

Arguments (used to override existing configuration):

a|action            - Sets action to one of: deploy (default), prepare, rollout, start, rollback.
                      Using this argument will have same effect as executing respective *.sh file.
c|checkout          - Overrides GIT_CHECKOUT.
d|dir               - Overrides DEPLOY_DIR.
e|env               - Overrides SERVER_ENV.
r|repo              - Overrides GITHUB_REPOSITORY.
t|token             - Overrides GITHUB_TOKEN.
                      (folder provided must have respective access permitions)
w|webhook           - Overrides WEBHOOK.
ws|webhook-shipped  - Overrides WEBHOOK_SHIPPED
wd|webhook-deployed - Overrides WEBHOOK_DEPLOYED
wr|webhook-released - Overrides WEBHOOK_RELEASED


Flags:

--y      - Forces confirmation prompts.
--help   - Prints help.
--info   - Prints current configuration.
--save   - Saves provided configuration.
--clean  - Does cleanup of DEPLOY_DIR during setup process.
--config - Starts interactive configuration update.

- Config -

GITHUB_TOKEN      - Github token with repository read access.
GITHUB_REPOSITORY - Github source code repository in format {user_name}/{repo_name}.
GIT_CHECKOUT      - Git branch or tag (supports \"latest\") with required code snapshot.
SERVER_ENV        - Server environment. Usually one of: test, integration, staging, production.
DEPLOY_DIR        - Location of the source file on server.
WEBHOOK           - (optional) URL used for notifications during deployment process.
WEBHOOK_SHIPPED   - (optional) URL used for slack notifications about shipping live.
WEBHOOK_DEPLOYED  - (optional) URL used for slack notifications about finished deployment.
WEBHOOK_RELEASED  - (optional) URL used for shipping registration service.

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

post () {
  local url="$1"
  local data="$2"

  curl -H "Content-Type: application/json" --data "$data" $url
}

notify () {
  local action="$1"
  local status="$2"

  log "[$status] $action"

  [[ "$WEBHOOK" != "" ]] && post $WEBHOOK $data

  if [[ "$action" == "deploy" && "$status" == "done" ]]
    then
      [[ "$WEBHOOK_SHIPPED" != "" ]] && post $WEBHOOK_SHIPPED "{\"sender\":\"$(hostname)\",\"appVersion\":\"$(getCurrentCheckout)\",\"appName\":\"$GITHUB_REPOSITORY\",\"apiVersion\":\"$(node -p "require('$DEPLOY_DIR/app/ecosystem.json').apps[0].env.API_VERSION || 'n/a'")\"}"

      [[ "$WEBHOOK_DEPLOYED" != "" ]] && post $WEBHOOK_DEPLOYED "{\"env\":\"$SERVER_ENV\",\"server\":\"$(hostname)\",\"checkout\":\"$(getCurrentCheckout)\",\"repository\":\"$GITHUB_REPOSITORY\",\"action\":\"$action\",\"status\":\"$status\"}"

      [[ "$WEBHOOK_RELEASED" != "" ]] && post $WEBHOOK_RELEASED "{\"applicationName\":\"$GITHUB_REPOSITORY\",\"version\":\"$(getCurrentCheckout)\",\"topic\":\"frontend\",\"releaseDate\":\"$(date --iso-8601=seconds)\",\"sendSlackMessage\":false}"
  fi
}
