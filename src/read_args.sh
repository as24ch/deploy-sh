for param in "$@"
  do
    keyVal=(${param//=/ })
    key="${keyVal[0]}"
    value="${keyVal[1]}"
    case "$key" in
      token)
        [[ "$value" != "" ]] && export GITHUB_TOKEN="$value"
        shift;;
      checkout)
        [[ "$value" != "" ]] && export GIT_CHECKOUT="$value"
        shift;;
      env)
        [[ "$value" != "" ]] && export SERVER_ENV="$value"
        shift;;
      repo)
        [[ "$value" != "" ]] && export GITHUB_REPOSITORY="$value"
        shift;;
      dir)
        [[ "$value" != "" ]] && export DEPLOY_DIR="$value"
        shift;;
      webhook)
        [[ "$value" != "" ]] && export WEBHOOK_URL="$value"
        shift;;
      action)
        [[ "$value" != "" ]] && action="$value"
        shift;;
      --y)
        is_confirmed="true"
        shift;;
      --save)
        should_save_config="true"
        shift;;
      --info)
        print_config
        exit 0;;
      --help)
        print_help
        exit 0;;
      --config)
        propmt_config
        write_config
        exit 0;;
    esac
  done