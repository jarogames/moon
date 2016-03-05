#!/bin/bash
#
VERSION=1507.29.17

source bashmagic.func
# prerequisite 
# backup


################################################ variables:
MOON=1
SUN=1
CITY=""
LONG=0    # longitude  like 50
LAT=0     # latitude like -16
TIMEsec=`date +%s`
VERB=0
AZ=1
ALT=1

CCITY[0]="prague";       LLAT[0]=50.0833; LLONG[0]=-14.4167;
CCITY[1]="rez"         ; LLAT[1]=50.167;  LLONG[1]=-14.35;
CCITY[2]="mnisek"      ; LLAT[2]=49.8665; LLONG[2]=-14.2618;
CCITY[3]="vladivostok" ; LLAT[3]=43.1318; LLONG[3]=-131.9235;
CCITY[4]="catania"     ; LLAT[4]=37.501;  LLONG[4]=-15.07417;
CCITY[5]="santatecla"  ; LLAT[5]=37.636;  LLONG[5]=-15.176;
CCITY[6]="fumicino"    ; LLAT[6]=41.7958; LLONG[6]=-12.2752;
CCITY[7]="pisa"        ; LLAT[7]=43.68333;LLONG[7]=-10.4;
CCITY[8]="munich"      ; LLAT[8]=48.35283;LLONG[8]=-11.782537;
###echo ${CITY[*]}

#  http://www.findlatitudeandlongitude.com/?loc=munich+airport

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
	echo 'for (( i=0; i<200; i++ )); do t=$(( `date +%s` + $i * 600 ));echo -n `date -d @$t`" "; ./moon    -sun   -t  @$t  -l catania ; done'
	echo 'for (( i=0; i<200; i++ )); do t=$(( `date +%s` + $i * 600 ));echo -n `date -d @$t`" "; ./moon      -t  @$t  -l catania ; done'
	echo "------------------------------------------------"
	echo ${CCITY[*]}
	echo "-----------------------------------------------------"
	echo "$0 --update_version; $0 --export; cp $0.exported ~/00_central/moon"
  ;;

    --export) #  join all files into one script
    echo "% created by $0 ...ver.$VERSION"
    perl perlexport.pl $0
   ;;

    -moon) #  show moon coordiantes
	MOON=1
	SUN=0
   ;;

    -sun) #  show sun coordiantes
	SUN=1
	MOON=0
   ;;
    -l|-loc) #  current location ... predefined city -l prague
	CITY=$1
	shift
	for (( i=0; i<${#CCITY[@]}; i++ ));do
	    if [ "$CITY" = "${CCITY[$i]}" ]; then
		LAT=${LLAT[$i]}; LONG=${LLONG[$i]}
	    if [ "$VERB" = 1 ]; then
		echo city /$i/  ${CCITY[$i]} $LAT $LONG
	    fi
	    fi
	done
	# if [ "$CITY" = "prague" ]; then LAT=50.0833;LONG=-14.4167;fi
	# if [ "$CITY" = "rez" ]; then LAT=50.167;LONG=-14.35;fi
	# if [ "$CITY" = "mnisek" ]; then LAT=49.8665;LONG=-14.2618;fi
	# if [ "$CITY" = "vladivostok" ]; then LAT=43.1318;LONG=-131.9235;fi
	# if [ "$CITY" = "catania" ]; then LAT=37.501;LONG=-15.07417;fi
	# if [ "$CITY" = "santatecla" ]; then LAT=37.636;LONG=-15.176;fi
	# if [ "$CITY" = "fumicino" ]; then LAT=41.7958;LONG=12.2752;fi
	# if [ "$CITY" = "pissa" ]; then LAT=43.68333;LONG=10.4;fi
   ;;
    -t|-time) #  time of obdervation ... "6:40 2015/9/9"   now
	TIME=$1
	shift
	TIMEsec=`date -d "$TIME" +%s`
#	echo $TIMEsec
   ;;

    -d|--debug) #  debug
	VERB=1
   ;;

    -az) #  azimut
	AZ=1
	ALT=0
   ;;
    -alt) #  altitude
	ALT=1
	AZ=0
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
	echo -n "MOON  azimut altitude (phase)  "
    fi
    echo " "
fi

###TIMEsec=$(( $TIMEsec - 3600    ))

REPLY=`perl domoon.pl $TIMEsec $LAT $LONG  $SM`
if [ "$SM" = "3" ]; then
    echo $REPLY
else
    if [  "$AZ" = "1" ];then
	if [ "$ALT" = "0"  ]; then
	    echo  $REPLY | awk '{print $1 " "}'
	else
	    #	    echo az1 alt1  HERE sun and moon go!
	    if [ "$SM" = "1" ]; then
		echo  $REPLY | awk '{print $1 " " $2 " "}'
	    else
		echo  $REPLY | awk '{print $1 " " $2 " " $3}'
	    fi
	fi
    fi
    
    if [  "$AZ" = "0" ]; then
	if  [  "$ALT" = "1" ] ; then
	    echo  $REPLY | awk '{print $2 " "}'
	fi
    fi
fi
### perl dosun.pl

if [[ -e $key ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $key
fi
