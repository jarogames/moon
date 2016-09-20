# MOON

## USAGE:

```
./moon.exported  -h
----------------------------------------------------
  -v|--version         ... print version
  --update-version     ... change the file version to now 
  -h|--help            ... help
  --export             ... join all files into one script
  -moon                ... show moon coordiantes
  -sun                 ... show sun coordiantes
  -l|-loc              ... current location ... predefined city -l prague
  -t|-time             ... time of obdervation ... "6:40 2015/9/9"   now
  -d|--debug           ... debug
  -az                  ... azimut
  -alt                 ... altitude
```

## SCRIPTS
-----------------------------------------------------
```
for (( i=0; i<200; i++ )); do t=$(( `date +%s` + $i * 600 ));echo -n `date -d @$t`" "; ./moon    -sun   -t  @$t  -l catania ; done
for (( i=0; i<200; i++ )); do t=$(( `date +%s` + $i * 600 ));echo -n `date -d @$t`" "; ./moon      -t  @$t  -l catania ; done
```


##PREDEFINED PLACES
------------------------------------------------
```prague rez mnisek vladivostok catania santatecla fumicino pisa munich```

## HOWTO EXPORT with bashmagick
-----------------------------------------------------
```./moon.exported --update_version; ./moon.exported --export; cp ./moon.exported.exported ~/00_central/moon```

