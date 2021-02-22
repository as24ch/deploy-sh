# Deployment Scripts

## Requirements
- \*nix system
- Git
- NodeJS
- PM2

## Instalation:

```bash
> git clone git@github.com:as24ch/deploy-sh.git ./deploy
> chmod +x ./setup.sh
> ./setup.sh
```

## Usage
After setting-up of the scripts you can trigger deployments by running `cli.sh`

## Help

### CLI
```
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
--config - Starts interactive configuration update.
```

### Config
```
GITHUB_TOKEN      - Github token with repository read access.
GITHUB_REPOSITORY - Github source code repository in format {user_name}/{repo_name}.
GIT_CHECKOUT      - Git branch or tag (supports "latest") with required code snapshot.
SERVER_ENV        - Server environment. Usually one of: test, integration, staging, production.
DEPLOY_DIR        - Location of the source file on server.
WEBHOK_URL        - (optional) URL used for notifications during deployment process.
```

### Files
```
cli.sh      - (recommended) Interactive command line interface.
prepare.sh  - Clones, installs dependencies and builds application in "next" folder of "DEPLOY_DIR".
rollout.sh  - Replaces "next" => "app" => "prev" folders in "DEPLOY_DIR" and runs "start.sh".
start.sh    - Starts / Re-starts application in "app" folder in "DEPLOY_DIR" using saved configuration.
rollback.sh - Replaces "prev" => "app" => "next" folders in "DEPLOY_DIR" and runs "start.sh".
              Used for rapid revert of the last deployment.
setup.sh    - Clean setup of deployments scripts.
              Warning! Will remove previously configured applications.
```
