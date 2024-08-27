#!/usr/bin/env bash
#set -x
HOME="tank/home"
ARCHIVE="tank/oldhome"

LOGFILE="rename_old.log"
if [ -f "${LOGFILE}" ] ; then
  echo "ERROR ${LOGFILE} found. Please rename or delete before proceeding."
  exit 1
fi
exec 3>"${LOGFILE}" 2>&1

declare -i daysago=730
dorename=false

usage()
{
    echo ""
    echo "Usage: $0 [-x] [-d <int:DAYS>]"
    echo ""
    echo " -x            : Rename filesystems. If this option is not set, the script"
    echo "                 will log the changes that would be made, but make no"
    echo "                 modifications"
    echo " -d <int:DAYS> : Directories with contents older than <DAYS> days will be"
    echo "                 removed. Default value: ${daysago}"
    echo ""
    exit 1
}

while getopts "xd:" opt; do
  case $opt in
    d) daysago=${OPTARG} ;;
    x) dorename=true ;;
    *)
      echo "Unrecognized argument \"${OPTARG}\""
      usage
  esac
done
shift $((OPTIND - 1))
olderthan=$(/usr/bin/date -d "-${daysago} days" '+%s')

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

HOMEDIR=$(/usr/sbin/zfs get -Hp -o value mountpoint ${HOME})
if [ $? -ne 0 ] ; then 
  echo "ERROR ${HOME} not found. Must specify target user home filesystem."
  exit 1
fi
declare -a HOMEDIRS=($(/usr/sbin/zfs list -Hp -o mountpoint -r -d 1 tank/home | tail -n +2))
	
ARCHIVEDIR=$(/usr/sbin/zfs get -Hp -o value mountpoint ${ARCHIVE})
if [ $? -ne 0 ] ; then
  echo "ERROR ${ARCHIVE} not found. Must specify target user archive filesysetem."
  exit 1
fi

echo "Examining ${#HOMEDIRS[@]} existing users."

###

#set -x
trap "echo 'ERROR: An error occurred during execution, check ${LOGFILE} for details.' >&3" ERR

log () {
  echo "[$(date -Is)]" "$@" >&3
}

declare -a FS=($(/usr/sbin/zfs list -Hp -o name -r -d 1 ${HOME} | tail -n +2))


newest_file() {
    local fs=$1
    local -n m=$2             # use nameref for indirection

    local directory=$(/usr/sbin/zfs get -Hp -o value mountpoint ${fs})
    m=( $(find "${directory}" -print0 | \
     xargs -0 stat --format '%Y "%n"' | \
     sort -n  | tail -n 1)
    )
}

main() {

  i=0
  for fs in "${FS[@]}" ; do

    i=$(($i + 1))

    if [[ $((i % 50)) -eq 1 ]] ; then
      echo "$i / ${#FS[@]}"
    fi

    declare -a modified
    newest_file "${fs}" modified

    owner=$(echo ${modified[1]} | cut -d'/' -f4 | sed 's/"//g')
    
    if [ "${modified[0]}" -lt "${olderthan}" ] ; then
      cmd="/usr/sbin/zfs rename ${fs} ${ARCHIVE}/${owner}"
      if [ $dorename = true ] ; then
        log "${owner},${modified[0]},${modified[@]:1} archived"
        ${cmd}
        if [ $? -ne 0 ] ; then
          log "ERROR: Unable to archive ${fs}"
          exit 1
        fi
      else
        log "${owner},${modified[0]},${modified[@]:1} would be archived"
        log "${cmd}"
      fi
    else
      log "${owner},${modified[0]},${modified[@]:1} active - no change" 
    fi
  done
}

echo ""
confirm "Users not seen since $(date -d@${olderthan}) will be archived, procceed [yN]?" 2>&1 && main
echo ""
