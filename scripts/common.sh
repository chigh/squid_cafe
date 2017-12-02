###########################################################################
## ID: common.sh                                                         ##
## DESCRIPTION: Common functions that aren't normally called on the      ##
##              command line. This is NOT to be run manually!            ##
## AUTHOR: Clair High <clair.high@tch3.com>                              ##
## VERSION: @(#)common.sh 3.0  2016-07-07                                ##
###########################################################################
# DEPRECIATED items are subject to removal without notice.                #
###########################################################################
# BASH options via set                                                    #
#   posix     Enables special POSIX builtins                              #
#   errexit   Exit on error. # Redundant                         # set -e #
#   errtrace  Exit on error inside any functions or subshells.            #
#   nounset   Exit on undefined variable. Use ${VAR:-}           # set -u #
#   pipefail  Exit even if a non-last command within a pipeline           #
#             encounters an error. (Remembers highest exit status)        #
#   verbose   Echo commands as they are executed                          #
#   xtrace    Trace what gets executed.                          # set -x #
# see also strict.sh                                                      #
###########################################################################
set -o errexit  # set -e
set -o errtrace # set -E
set -o nounset  # set -u
set -o pipefail
set -o posix
#set -o verbose
#set -o xtrace  # set -x
###########################################################################
VERSION=3.0
COMMON=true
DEFAULT_IFS="${IFS}"
SAFER_IFS=$'\n\t'
#IFS="${SAFER_IFS}"
IFS="${DEFAULT_IFS}"
DOTHOME="${HOME}/.files"
NOW="$(TZ=UTC date +%s)";
OPTIND=1 # Reset in case getopts has been used previously in the shell.
TMPDIR=/tmp
TZ="$(date +%Z)"
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
LOG_DIR="${HOME}/Library/logs"
NO_COLOR="${NO_COLOR:-}"    # true = disable color. otherwise autodetected

## Set magic variables
###########################################################################
__dir="$(cd "$(dirname "$0")" && pwd)"
__file="${__dir}/$(basename ${0})"
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
#__file="${__dir}/$(basename "${BASH_SOURCE[1]}")"
__base="$(basename ${__file} .sh)" 
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__me=$(basename "${0}")
__arch=$(uname -m)
__system=$(uname -s)

if [ "$#" -eq 0 ]; then
  __args=( 0 )
else
  __args=( "$@" )
fi

__arg1=${1:-}

## declare some variables for use later
###########################################################################
declare debug
declare error_msg
declare mug
declare opt
declare __usage
declare __helptext
declare -a pipe_status

## Number of columns to move cursor
###########################################################################
if [[ -z ${RES_COL:-} ]]
then
    unset RES_COL
    COLUMNS=$(tput cols)
    let col=COLUMNS-5
    if [[ $col -gt 125 ]]
        then let col=125
    fi
    RES_COL=$col
fi
MOVE_TO_COL="printf \\033[${RES_COL}G" # Move the curser $RES_COL columns #

## Usage / Help Example
###########################################################################
# Commandline options. This defines the usage page, and is used to parse cli
# opts & defaults from. The parsing is unforgiving so be precise in your syntax
# - A short option must be preset for every long option; but every short option
#   need not have a long option
# - `--` is respected as the separator between options and arguments
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -f --file  [arg] Filename to process. Required.
  -t --temp  [arg] Location of tempfile. Default="/tmp/bar"
  -v               Enable verbose mode, print script as it is executed
  -d --debug       Enables debug mode
  -h --help        This page
  -n --no-color    Disable color output
  -1 --one         Do just one thing
EOF
read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
 This is Bash3 Boilerplate's help text. Feel free to add any description of your
 program or elaborate more on command-line arguments. This section is not
 parsed and will be added as-is to the help.
 https://github.com/kvz/bash3boilerplate
EOF

## Functions
###########################################################################
_depreciated () { error "DEPRECIATED"; exit 1; };
_empty ()       { :; }
_err_pre ()     { printf "${red}error:${reset}"; }
_err_404 ()     { _err_pre ; printf "file not found $missing_file\n"; }
_err_arg ()     { _err_pre ; printf "missing argument\n"; }
_err_trap()     { trap 'err_report "${FUNCNAME:-.}" $LINENO' ERR; }
_int_trap ()    { trap "{ printf '\n'; alert \"caught interrupt: exiting\"; exit_status="2"; exit 2; }" INT; }
_load_help ()   { [[ ${__arg1} = "-h" || ${__arg1} = *'help' ]] && _usage &&  exit 1 || true; }
_loading ()     { printf "Loading "$@" ... "; }
_move_to_col () { unset MOVE_TO_COL; MOVE_TO_COL="printf \\033[${RES_COL}G"; }
_pause ()       { printf "Press ENTER to continue: " ; read pause; unset pause; }
_separator ()   { printf "%0.s-" {1..75} ; printf "\n" ; }
_verbose ()     { set -o verbose; }
_xtrace ()      { set -o xtrace; }
_no_xtrace ()   { set +o xtrace; }
_errexit ()     { set -o errexit; }
_no_errexit()   { set +o errexit; }
_quiet ()       { set +o xtrace; set +o verbose; }

cleanPath ()    { export PATH="/usr/sbin:/usr/local/bin:/usr/local/sbin"; }
cutcol ()       { cut -c 1-$(tput cols) || cut -c 1-${COLUMNS}; }
ding ()         { printf ""; }
now ()          { unset NOW; NOW="$(TZ=UTC date +%s)"; }
null ()         { cat /dev/null > "$@"; }
pipe_status ()  { pipe_status=(${PIPESTATUS[@]}); }
sleepy ()       { sleep 1; }

_usage ()       {
  #echo "" 1>&2 #echo "${@}" 1>&2
  echo " " 1>&2
  echo "Usage: ${__me}  ${__usage:-No usage available}" 1>&2
  echo "" 1>&2
  echo " ${__helptext:-}" 1>&2
  echo "" 1>&2
  exit 1
}

# error_status () { printf "$(_fmt error): ${error_msg}\n" 1>&2 || true; } # DEPRECIATED  # see set_err
# loading ()       { printf "${b_yellow}loading()${reset} is depreciated; use ${b_green}_loading()${reset}\n" ; sleep 1; _loading "$@"; } # DEPRECIATED
# set_err ()      { error_msg="${@}"; } # DEPRECIATED

_fmt () {
    local color_debug="${purple}"
    local color_info="${green}"
    local color_notice="${blue}"
    local color_warning="${yellow}"
    local color_error="${red}"
    local color_critical="${b_red}"
    local color_alert="${b_yellow}"
    local color_emergency="${u_yellow}"
    local colorvar=color_${1:-}

    local color="${!colorvar:-$color_error}"
    local color_reset="${reset}"
    if [ "${NO_COLOR}" = "true" ] || [[ "${TERM:-}" != "xterm"* ]] || [ -t 1 ]; then
    # Don't use colors on pipes or non-recognized terminals
        color=""; color_reset=""
    fi
    #echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" ${1})${color_reset}";
    #echo -e "$(date -u +"%F %T %Z") ${color}$(printf "[%9s]" ${1})${color_reset}"; 
    echo -e "${color}$(printf "[%9s]" ${1})${color_reset}"; 
}

emergency () {                             echo "$(_fmt emergency) ${@}" 1>&2 || true; exit 1; }
alert ()     { [ "${LOG_LEVEL}" -ge 1 ] && echo "$(_fmt alert) ${@}" 1>&2 || true; }
critical ()  { [ "${LOG_LEVEL}" -ge 2 ] && echo "$(_fmt critical) ${@}" 1>&2 || true; }
error ()     { [ "${LOG_LEVEL}" -ge 3 ] && echo "$(_fmt error) ${@}" 1>&2 || true; }
warning ()   { [ "${LOG_LEVEL}" -ge 4 ] && echo "$(_fmt warning) ${@}" 1>&2 || true; }
notice ()    { [ "${LOG_LEVEL}" -ge 5 ] && echo "$(_fmt notice) ${@}" 1>&2 || true; }
info ()      { [ "${LOG_LEVEL}" -ge 6 ] && echo "$(_fmt info) ${@}" 1>&2 || true; }
debug ()     { [ "${LOG_LEVEL}" -ge 7 ] && echo "$(_fmt debug) ${@}" 1>&2 || true; }

_hr () {  # see also separator
    chars=${1:-}
    [[ -z $chars ]] && chars="$(tput cols)"
    printf '%0.s-' $(seq 1 $chars); printf "\n"
}

adddate () { # Adds date stamp to ALL lines of output. 
    if [[ -z $TAG ]]; then TAG=${__me}; fi

    while IFS= read -r line; do
        printf "%s %s\n" "$(date "+%F %T %Z") $TAG" "$line"
    done
}

argind () { 
    printf "\$#:" ; $MOVE_TO_COL ; printf "$#\n"
    printf "OPTIND:" ; $MOVE_TO_COL ; printf "$OPTIND\n"
    exit $?; 
}

exit_status () {     # $pipe_status must be set; see pipe_status
    pipe_status=(${PIPESTATUS[@]})
    for i in ${pipe_status[@]}
      do let exit_status=exit_status+i
    done
    return $exit_status
}

logstamp () {
    if [[ $epoch == 1 ]]
    then
        while IFS= read -r line
        do
            printf "$(date '+%s.%N') $line\n"
        done
    else
        while IFS= read -r line
        do
            printf "$(date '+%F %T.%N') $line\n"
        done
    fi
}

pidof () {
	if [[ "$__system" == "Darwin" ]]
	  then ps axc|awk "{if (\$5==\"$1\") print \$1}";
	  else /bin/pidof $@
	fi
}

## Status/Colored Messages
###########################################################################
# Regular          Bold Text            Underline             Background
blue="\e[0;34m";   b_blue="\e[1;34m";   u_blue="\e[4;34m";    bg_blue="\e[44m";   bl_blue="\e[34;5m";
black="\e[0;30m";  b_black="\e[1;30m";  u_black="\e[4;30m";   bg_black="\e[40m";  bl_black="\e[30;5m";
cyan="\e[0;36m";   b_cyan="\e[1;36m";   u_cyan="\e[4;36m";    bg_cyan="\e[46m";   bl_cyan="\e[36;5m";
green="\e[0;32m";  b_green="\e[1;32m";  u_green="\e[4;32m";   bg_green="\e[42m";  bl_green="\e[32;5m";
purple="\e[0;35m"; b_purple="\e[1;35m"; u_purple="\e[4;35m";  bg_purple="\e[45m"; bl_purple="\e[35;5m";
red="\e[0;31m";    b_red="\e[1;31m";    u_red="\e[4;31m";     bg_red="\e[41m";    bl_red="\e[31;5m";
white="\e[0;37m";  b_white="\e[1;37m";  u_white="\e[4;37m";   bg_white="\e[47m";  bl_white="\e[37;5m";
yellow="\e[0;33m"; b_yellow="\e[1;33m"; u_yellow="\e[4;33m";  bg_yellow="\e[43m"; bl_yellow="\e[33;5m";
reset="\e[0m"

success () { $MOVE_TO_COL; printf "[ ${green}OK${reset} ]\n"; }
fail ()    { $MOVE_TO_COL; printf "[${red}FAIL${reset}]\n"; }
on ()      { $MOVE_TO_COL; printf "[${green}+${reset}]\n"; }
off ()     { $MOVE_TO_COL; printf "[${red}-${reset}]\n"; }
skip ()    { $MOVE_TO_COL; printf "[${yellow}SKIP${reset}]\n"; }

## Error Trapping 
###########################################################################
err_report () {
    error_code=$?
    #printf "Error in $__file in function $1 on line $2\n"
    printf "Error in function $1 on line $2\n"
    exit $error_code
}
#trap 'err_report "${FUNCNAME:-.}" $LINENO' ERR

## Scratch directory - Contents deleted after script exits
###########################################################################
scratch=$(mktemp -d -t tmp.XXXXXXXXXX) # $scratch will be auto-deleted on
finish () { rm -rf $scratch ; }         # exit no matter the exit status
trap finish EXIT INT

# All output to syslog and stderr (edanel)
###########################################################################
# exec 1> >(logger -s -t ${TAG}) 2>&1
###########################################################################
# if [[ $mug = 1 ]]; then source ~/bin/mug.sh; fi
###########################################################################
unset opt
export -f logstamp _pause
