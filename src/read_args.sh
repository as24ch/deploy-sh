for param in "$@"
  do
    keyVal=(${param//=/ })
    key="${keyVal[0]}"
    value="${keyVal[1]}"
    case "$key" in
      a|action)
        [[ "$value" != "" ]] && action="$value"
        shift;;
      c|checkout)
        [[ "$value" != "" ]] && export GIT_CHECKOUT="$value"
        shift;;
      d|dir)
        [[ "$value" != "" ]] && export DEPLOY_DIR="$value"
        shift;;
      e|env)
        [[ "$value" != "" ]] && export SERVER_ENV="$value"
        shift;;
      r|repo)
        [[ "$value" != "" ]] && export GITHUB_REPOSITORY="$value"
        shift;;
      t|token)
        [[ "$value" != "" ]] && export GITHUB_TOKEN="$value"
        shift;;
      w|webhook)
        [[ "$value" != "" ]] && export WEBHOOK="$value"
        shift;;
      ws|webhook-shipped)
        [[ "$value" != "" ]] && export WEBHOOK_SHIPPED="$value"
        shift;;
      wd|webhook-deployed)
        [[ "$value" != "" ]] && export WEBHOOK_DEPLOYED="$value"
        shift;;
      wr|webhook-released)
        [[ "$value" != "" ]] && export WEBHOOK_RELEASED="$value"
        shift;;
      --y)
        is_confirmed="true"
        shift;;
      --help)
        print_help
        exit 0;;
      --info)
        print_config
        exit 0;;
      --save)
        should_save_config="true"
        shift;;
      --clean)
        is_clean="true"
        shift;;
      --config)
        propmt_config
        write_config
        exit 0;;
    esac
  done
