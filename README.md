# Deployment Scripts

## Requirements
- Linux
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
```

### Config
```
GITHUB_TOKEN      - Github token with repository read access
GITHUB_REPOSITORY - Github source code repository in format {user_name}/{repo_name}
GIT_CHECKOUT      - Git branch or tag (supports "latest") with required code snapshot
SERVER_ENV        - Server environment. Usually one of: test, integration, staging, production
DEPLOY_DIR        - Location of the source file on server
WEBHOK_URL        - URL used for notifications during deployment process (Optional)
```

### Files
```
cli.sh      - Interactive command line interface (Recommended)
prepare.sh  - Clones, installs dependencies and builds application in "next" folder of "DEPLOY_DIR"
rollout.sh  - Replaces "next" => "app" => "prev" folders in "DEPLOY_DIR" and runs "start.sh"
start.sh    - Starts / Re-starts application in "app" folder in "DEPLOY_DIR" using saved configuration
rollback.sh - Replaces "prev" => "app" => "next" folders in "DEPLOY_DIR" and runs "start.sh"
              Used for rapid revert of the last deployment
setup.sh    - Clean setup of deployments scripts
              Warning! Will remove previously configured applications
```
