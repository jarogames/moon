#!/bin/bash
#
VERSION=1507.29.17

source bashmagic.func
# prerequisite 
# backup


################################################ variables:
MOON=0
SUN=0
CITY=""
LONG=0    # longitude  like 50
LAT=0     # latitude like -16
TIMEsec=`date +%s`
VERB=0



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

    -moon) #  show moon coordiantes
     MOON=1
   ;;

    -sun) #  show sun coordiantes
     SUN=1
   ;;
    -l|-loc) #  current location ... predefined city -l prague
	CITY=$1
	shift
	if [ "$CITY" = "prague" ]; then LAT=50.0833;LONG=-14.4167;fi
	if [ "$CITY" = "rez" ]; then LAT=50.167;LONG=-14.35;fi
	if [ "$CITY" = "mnisek" ]; then LAT=49.8665;LONG=-14.2618;fi
	if [ "$CITY" = "vladivostok" ]; then LAT=43.1318;LONG=-131.9235;fi
	if [ "$CITY" = "catania" ]; then LAT=37.501;LONG=-15.07417;fi
   ;;
    -t|-time) #  time of obdervation ... \"6:40 2015/9/9 CEST\"
	TIME=$1
	shift
	TIMEsec=`date -d "$TIME" +%s`
#	echo $TIMEsec
   ;;

    -d|--debug) #  debug
	VERB=1
   ;;



   *)            # unknown option
	echo unknown option : $key
	
   ;;
esac
done

####################################################

SM=$(( $SUN + $MOON * 2))

TIME=`date -d \@$TIMEsec`
#echo VERB=$VERB
if [ "$VERB" = "1" ]; then
    echo ... verbose mode 
    echo ... calculating in $CITY \($LAT $LONG\) at /$TIME/: SUN=$SUN MOON=$MOON\; $SM
    if [ "$SUN" = "1" ]; then
	echo -n "SUN azimut    altitude  "
    fi
    if [ "$MOON" = "1" ]; then
	echo -n "MOON  azimut altitude phase  "
    fi
    echo " "
fi

###TIMEsec=$(( $TIMEsec - 3600    ))

perl domoon.pl $TIMEsec $LAT $LONG  $SM

### perl dosun.pl

if [[ -e $key ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $key
fi
