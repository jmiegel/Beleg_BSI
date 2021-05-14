#!/bin/bash

#****************
# debug
#****************
#set -x

#****************
# error handling
#****************
set -e
set -u
set -o pipefail

#****************
# function to choose needed files and to write them into one file
#****************
choose_files () {
  if [[ $1 = "all" ]]
    then cat auth* >> NEEDED.txt
  else
    cat auth-$1* >> NEEDED.txt
  fi
}


#****************
# parameter check
#****************
if [[ $# -lt 2 ]]; then
  echo -e "2 parameters are needed\nfirst parameter can be ipo51, ipc88, ilpro122, fohls or all\n
          second parameter can be root, users, login\nPlease try again."
  exit 1
fi

# not correct first parameter
if [[ $1 != "ipo51" ]] && [[ $1 != "ipc88" ]] && [[ $1 != "ilpro122" ]] && [[ $1 != "fohls" ]]&& [[ $1 != "all" ]]; then
  echo "Unknown first parameter. Has to be ipo51, ipc88, ilpro122, fohls or all."
  exit 1
fi

# not correct second parameter
if [[ $2 != "root" ]] && [[ $2 != "users" ]] && [[ $2 != "login" ]]; then
  echo "Unknown second parameter. Has to be root, users or login."
  exit 1
fi


#***************
# create temporary directory
#**************
MY_TEMPDIR=$(mktemp -d)
trap 'rm -fdr "$MY_TEMPDIR"' EXIT

#***************
# get data recursive, save into TEMPDIR and decompress .gz
#***************
wget -nd -P $MY_TEMPDIR -r -A "*.log*" http://ilpro122.informatik.htw-dresden.de/logs/#http://ilpro122.infor.htw-dresden.de/logs/

echo "runtergeladen ****"
ls $MY_TEMPDIR
cd $MY_TEMPDIR
gzip -d *.gz
#cd ..
echo "ausgepackt *******"
#ls $MY_TEMPDIR

#***************
# data analysis
#***************
# create temporary file

choose_files $1

#MY_TEMPFILE=$(mktemp)

#case "$1" in
#  all)      choose_files
#            ;;
#  fohls)    cat auth-fohls* >> NEEDED.txt
#            ;;
#  ilpro122) cat auth-ilpro122* >> NEEDED.txt
#            ;;
#  ipc88)    cat auth-ipc88* >> NEEDED.txt
#            ;;
#  ipo51)    cat auth-ipo51* >> NEEDED.txt
#esac

cat NEEDED.txt

ls











exit 0
