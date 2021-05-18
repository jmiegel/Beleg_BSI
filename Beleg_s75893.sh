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
exec 2>> /dev/null

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
if ! MY_TEMPDIR=$(mktemp -d) ; then
  echo "Unable to create temporary directory"
  exit 2
fi
trap 'rm -fdr "$MY_TEMPDIR"' EXIT

#***************
# get data recursive, save into TEMPDIR and decompress .gz
#***************
echo "Downloading files from ilpro122.informatik.htw-dresden.de/logs/ "

if ! wget -nd -P $MY_TEMPDIR -r -A "*.log*" http://ilpro122.informatik.htw-dresden.de/logs/ ; then
  echo "Unable to download logfiles"
  exit 3
fi

cd $MY_TEMPDIR
echo "Unziping files"
if ! gzip -d *.gz ; then
  echo "Unable to unzip logfiles"
  exit 4
fi
#***************
# data analysis
#***************
echo -e "Analyzing data\n\n"

# create temporary file
choose_files $1

# evaluate data
case "$2" in
  root)   grep -P "Failed password for root from" NEEDED.txt |
          grep -oP "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" |
          sort | uniq -c |
          awk 'BEGIN { printf "%s %s\n", "IP-Adress", "Frequency"
                                        printf "%s %s\n", "--------", "---------" }
                                      { printf "%s %s\n", $2, $1 }' | column -t
          ;;
  users)  grep -P "Failed password for invalid user" NEEDED.txt |
          grep -oP "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" |
          sort | uniq -c |
          awk 'BEGIN { printf "%s %s\n", "IP-Adress", "Frequency"
                                        printf "%s %s\n", "--------", "---------" }
                                      { printf "%s %s\n", $2, $1 }' | column -t
          ;;
  login)  grep -oP "(?<=Failed password for invalid user )[A-Za-z0-9]{1,}" NEEDED.txt |
          sort | uniq -c | sort -n |
          awk 'BEGIN { printf "%s %s\n", "Username", "Frequency"
                                                  printf "%s %s\n", "--------", "---------" }
                                                { printf "%s %s\n", $2, $1 }' | column -t
          ;;
esac

cd ..
rm -r $MY_TEMPDIR
exit 0
