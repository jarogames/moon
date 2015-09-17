#!/bin/bash
#
VERSION=1507.29.17

source bashmagic.func
# prerequisite 
# backup

while [[ $# > 0 ]]
do

key="$1"
shift

case $key in
    -v|--version)   # print version
    echo $VERSION
  ;;
    --update-version)  #  change the file version to now 
       bm_update_version
  ;;
    -h|--help)  # help
	# important to have an inline comment for every option!
	perl showoptions.pl $0 
	echo "-----------------------------------------------------"
	echo "$0 --update_version; $0 --export; cp $0.exported ~/"
  ;;

    --export) #  join all files into one script
    echo "% created by $0 ...ver.$VERSION"
    perl perlexport.pl $0
   ;;

    -t) # test
    echo TEST
   ;;

   *)            # unknown option
	echo unknown option : $key
	
   ;;
esac
done


if [[ -e $key ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $key
fi
