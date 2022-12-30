#!/bin/zsh

# set -Eeuo pipefail TODO: figure out what to do with that

# [ -z ${cmd_running+x} ] && __cmd_err_msg "Interanl function of ${GREEN}cmd${RESET} task runner" && return 1



function cmd() {
	trap __cmd_cleanup SIGINT SIGTERM ERR EXIT

	cmd_running=1
	cmd_script_file=${(%):-%x}
	cmd_script_dir=$(cd "$(dirname $cmd_script_file)" &>/dev/null && pwd -P)

	__cmd_setup_colors
	__cmd_parse_params "$@"
}

function __cmd_usage() {

echo "$(
cat <<EOF
${ORANGE_DARK}USAGE:${RESET}
	${GREEN}$(basename $cmd_script_file)${RESET} <SUBCOMMAND> [SUBCOMMAND PARAMS]

${ORANGE_DARK}SUBCOMMANDS:${RESET}

	${YELLOW}show-proc-on-port${RESET} ${GREEN_MELLOW}<p>${RESET}    Display all processes running on a given port [<p> - Port]            
	${YELLOW}cs-resolve-tree${RESET} ${GREEN_MELLOW}<lib>${RESET}    Resolve dependencies of a given coursier library [<lib> - library installed by coursier]
	${YELLOW}cs-install-java ${RESET}         Install java via coursier 
	${YELLOW}cs-chage-java${RESET}            Set current java from the list of installed versions
	${YELLOW}cs-change-java-tmp${RESET}       Set current java from the list of installed versions only for the current session
	${YELLOW}docker-stop-conts${RESET}        Stop all running docker containers
	${YELLOW}docker-rm-conts${RESET}          Remove all docker containers
	${YELLOW}docker-rm-images${RESET}         Remove all docker images
EOF
)"


}

function __cmd_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  unset cmd_script_file cmd_script_dir
  unset RESET RED GREEN ORANGE_DARK YELLOW GREEN_MELLOW
  unset cmd_running
}

function __cmd_setup_colors() {

	# usage of 256 colors: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
	# told: \033[38;5;<color from 1 to 256>;m

  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    RESET='\033[0m'
    RED='\033[0;31m' 
    GREEN='\033[0;32m'  
    ORANGE_DARK='\033[0;38;5;172m'
    YELLOW='\033[0;33m'
    GREEN_MELLOW='\033[0;38;5;120m'
  else
    RESET='' RED='' GREEN='' ORANGE_DARK='' YELLOW='' GREEN_MELLOW=''
  fi
}

function __cmd_die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  __err_msg "$msg"
  exit $code
}

function __cmd_err_msg() {
  echo >&2 -e $1
}

function __cmd_missing_required_param_err() {
	__cmd_err_msg "${RED}Required Parameter - $1 is missing${RESET}"
}

function __cmd_parse_params() {
	source "$cmd_script_dir/functions.zsh"
  
  # TODO: support positional parameters for subcommands
	case ${1-} in
		"" |-h | --help)
		__cmd_usage
		;;
		show-proc-on-port) 
		if [[ ! ${2-} ]] __cmd_missing_required_param_err "Port" && return 1
		__cmd_functions_show_processes_on_port $2
		;;
	    cs-resolve-tree)
		if [[ ! ${2-} ]] __cmd_missing_required_param_err "Lib" && return 1
		__cmd_functions_cs_resolve_tree $2
		;;
		cs-install-java) 
		__cmd_functions_cs_install_java
		;;
		cs-change-java)
		__cmd_functions_cs_change_java
		;;
		cs-change-java-tmp) 
		__cmd_functions_cs_change_java_tmp 
		;;
		docker-stop-conts) 
		__cmd_functions_docker_stop_conts
		;;
		docker-rm-conts) 
		__cmd_functions_docker_rm_conts
		;;
		docker-rm-images) 
		__cmd_functions_docker_rm_images
		;;
		*) 
		__cmd_err_msg "Invalid subcommand"
		;;
    esac	

  return 0
}
