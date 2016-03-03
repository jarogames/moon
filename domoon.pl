#!/usr/bin/perl
use Time::Local;

sub calculate{

########################################################
########################################################
sub acos {my $z = $_[0]; atan2(sqrt(1-$z*$z), $z)}
sub asin {my $z = $_[0]; atan2($z, sqrt(1-$z*$z))}
sub subtend{
     my($ra1,$dec1,$ra2,$dec2)=@_;
        $ra1 = $ra1 / $HRS_IN_RADIAN;
        $dec1 = $dec1 / $DEG_IN_RADIAN;
        $ra2 = $ra2 / $HRS_IN_RADIAN;
        $dec2 = $dec2 / $DEG_IN_RADIAN;
        $x1 = cos($ra1)*cos($dec1);
        $y1 = sin($ra1)*cos($dec1);
        $z1 = sin($dec1);
        $x2 = cos($ra2)*cos($dec2);
        $y2 = sin($ra2)*cos($dec2);
        $z2 = sin($dec2);
        $theta = acos($x1*$x2+$y1*$y2+$z1*$z2);
#     /* use flat Pythagorean approximation if the angle is very small
#        *and* you're not close to the pole; avoids roundoff in arccos. */
        if($theta < 1.0e-5) {  # seldom the case, so don't combine test
                if(abs($dec1) < ($PI/2. - 0.001) &&
                    abs($dec2) < ($PI/2. - 0.001)) {
                        $x1 = ($ra2 - $ra1) * cos(($dec1+$dec2)/2.);
                        $x2 = $dec2 - $dec1;
                        $theta = sqrt($x1*$x1 + $x2*$x2);
                }
        }
  return $theta;
}
sub alt{
  my($ra,$dec,$lat)=@_;
        $ha = &adj_time($lst - $ra);
        $dec = $dec / $DEG_IN_RADIAN;
        $ha = $ha / $HRS_IN_RADIAN;
        $lat = $lat / $DEG_IN_RADIAN;
        $x = $DEG_IN_RADIAN * asin(cos($dec)*cos($ha)*cos($lat) +
                 sin($dec)*sin($lat));
        return $x;
}
sub az{
  my($ra,$dec,$lat)=@_;
        $ha = &adj_time($lst - $ra);
        $dec = $dec / $DEG_IN_RADIAN;
        $ha = $ha / $HRS_IN_RADIAN;
        $lat = $lat / $DEG_IN_RADIAN;
        $y = sin($dec)*cos($lat) - cos($dec)*cos($ha)*sin($lat);
        $z = -1. * cos($dec)*sin($ha);
        $x = atan_circ($y,$z) * $DEG_IN_RADIAN;
	return $x;
}
sub atan_circ{
       my($x,$y)=@_;
       $theta=0.;
       if($x == 0.) {
                if($y > 0.) {
                         $theta = $PI / 2.;
                }elsif($y < 0.){
                         $theta = 3.* $PI / 2.;
                }else{ $theta = 0.;}
        }else{
          $theta = atan2($y/$x,1);
        }
        if($x < 0.) {$theta = $theta + $PI;}
        if($theta < 0.) {$theta = $theta + 2.* $PI;}
        return $theta;
}
sub lpmoon{
              $T = ($jd - $J2000) / 36525.;

        $lambda = 218.32 + 481267.883 * $T
           + 6.29 * sin((134.9 + 477198.85 * $T) / $DEG_IN_RADIAN)
           - 1.27 * sin((259.2 - 413335.38 * $T) / $DEG_IN_RADIAN)
           + 0.66 * sin((235.7 + 890534.23 * $T) / $DEG_IN_RADIAN)
          + 0.21 * sin((269.9 + 954397.70 * $T) / $DEG_IN_RADIAN)
           - 0.19 * sin((357.5 + 35999.05 * $T) / $DEG_IN_RADIAN)
           - 0.11 * sin((186.6 + 966404.05 * $T) / $DEG_IN_RADIAN);
        $lambda = $lambda / $DEG_IN_RADIAN;
        $beta = 5.13 * sin((93.3 + 483202.03 * $T) / $DEG_IN_RADIAN)
           + 0.28 * sin((228.2 + 960400.87 * $T) / $DEG_IN_RADIAN)
           - 0.28 * sin((318.3 + 6003.18 * $T) / $DEG_IN_RADIAN)
           - 0.17 * sin((217.6 - 407332.20 * $T) / $DEG_IN_RADIAN);
        $beta = $beta / $DEG_IN_RADIAN;
        $pie = 0.9508
           + 0.0518 * cos((134.9 + 477198.85 * $T) / $DEG_IN_RADIAN)
           + 0.0095 * cos((259.2 - 413335.38 * $T) / $DEG_IN_RADIAN)
           + 0.0078 * cos((235.7 + 890534.23 * $T) / $DEG_IN_RADIAN)
           + 0.0028 * cos((269.9 + 954397.70 * $T) / $DEG_IN_RADIAN);
        $pie = $pie / $DEG_IN_RADIAN;
        $distance = 1. / sin($pie);

        $l = cos($beta) * cos($lambda);
        $mq = 0.9175 * cos($beta) * sin($lambda) - 0.3978 * sin($beta);
        $n = 0.3978 * cos($beta) * sin($lambda) + 0.9175 * sin($beta);

        $x = $l * $distance;
        $y = $mq * $distance;
        $z = $n * $distance;  # for topocentric correction
        $rad_lat = $latitude / $DEG_IN_RADIAN;
        $rad_lst = $lst / $HRS_IN_RADIAN;
        $x = $x - cos($rad_lat) * cos($rad_lst);
        $y = $y - cos($rad_lat) * sin($rad_lst);
        $z = $z - sin($rad_lat);

	$topo_dist = sqrt($x * $x + $y * $y + $z * $z);

        $l = $x / $topo_dist;
        $mq = $y / $topo_dist;
        $n = $z / $topo_dist;

        $alpha = &atan_circ($l,$mq);
        $delta = asin($n);
        $ra_moon = $alpha * $HRS_IN_RADIAN;
        $dec_moon = $delta * $DEG_IN_RADIAN;
        $dist_moon = $topo_dist;
	return;
}
sub lpsun{
        $n=$jd-$J2000;
        $L= 280.460 + 0.9856474 * $n;
        $g = (357.528 + 0.9856003 * $n)/$DEG_IN_RADIAN;
        $lambda = ($L + 1.915 * sin($g) + 0.020 *
                  sin(2. * $g))/$DEG_IN_RADIAN;
        $epsilon = (23.439 - 0.0000004 * $n)/$DEG_IN_RADIAN;
        $x = cos($lambda);
        $y = cos($epsilon)* sin($lambda);
        $z = sin($epsilon)* sin($lambda);
        $ra_sun = (atan_circ($x,$y))*$HRS_IN_RADIAN;
        $dec_sun = (&asin($z))*$DEG_IN_RADIAN;
}
sub adj_time{
  my($x)=@_;
  if (abs($x)<100000){
     while($x>12){         $x=$x-24;     }
     while($x<-12){          $x=$x+24;     }
  }
  return $x;
}
sub date_to_jd{
  $dayq=$day;
  $yearq=$year;
  $monthq=$month;
  $t=$dtime;
  if ($monthq<=2){
    $yearq=$yearq-1;
    $monthq=$monthq+12;
  }
  $a=int($year/100);
  $b=2-$a+int($a/4);
  $dayq+=$t/24;
  $jdg=int(365.25*($yearq+4716))+int(30.6001*($monthq+1))+$dayq+$b-1524.5;
  $jdg-=$tzone/24;
  $jd0=int($jdg+0.5)-0.5;
  $jd1=$jd0+(($t-$tzone)/24);
  if (($t-$tzone)>=24){
    $jd1-=1
  }
  $jd=$jd1;
  return $jd;
}
sub longcorr{
 $lngtd= -$longitude;
## $tzone=int($lngtd/15);  #!!!!!!!!!!!!1 round
 $qioi=abs(  ($lngtd/15)-int($lngtd/15) );
 if ($qioi<=0.5){
     $tzone=int($lngtd/15);
 }elsif(($lngtd/15)>int($lngtd/15)){
     $tzone=int($lngtd/15)+1;
 }else{
     $tzone=int($lngtd/15)-1;
 }
 $tzone+=$cdst;
 $degcorr=$lngtd-15*$tzone;
 return $tzone;
}

sub calc_lst{
 $ut=0;$jdmid=0;$sid_g=0;$sid=0;$sid_int=0;

 $jdint=int($jd);
 $jdfrac=$jd-$jdint;
 if ($jdfrac<0.5){
   $jdmid=$jdint - 0.5;
   $ut=$jdfrac + 0.5;
 } else {
   $jdmid=$jdint + 0.5;
   $ut=$jdfrac - 0.5;
 }
 $t=($jdmid - $J2000)/36525;
 $sid_g=(24110.54841+8640184.812866*$t+0.093104*$t*$t-0.0000062*$t*$t*$t)
      /$SEC_IN_DAY;
 $sid_g-=int($sid_g);
 $sid_g+=1.0027379093 * $ut - $longitude/360;
 $sid_g=($sid_g - int($sid_g))*24;
 if ($sid_g<0){   $sid_g+=24  }
 $lst=$sid_g;
 return $lst;
}




###############################################################################
###############################################################################
###############################################################################
###############################################################################
my($h,$m,$s,$day,$month,$year,$londeg,$latdeg)=@_;
###my($h,$m,$s,$day,$month,$year,$londeg,$latdeg)=@_;

#################### SOMEDATA
my $longdir=+1;  #kladny jsou west    my jsme east
my $latdir=+1;   #kladny je north     my jsme north

#my $londeg=-50; 
my $lonmin=0;
#my $latdeg=30; 
my $latmin=0;


my $cdst=0;   #daylight saving time - nepouzivat, pouzivat GMT
my $dh;

my $MOONONLY=0;
my $SUNONLY=0;



#  print "XXX; @_\n";

 $slunovr=timelocal(0,22-1,20,21,12-1,2001-1900);# den, kdy bylo 90->jihu
 $dnes=timelocal($s,$m,$h,$day,$month-1,$year-1900);
 $castroku=($dnes-$slunovr)/(365.256*24*3600)-int(($dnes-$slunovr)/(365.256*24*3600));
#print  "secnds: $slunovr\n";
#print  "secnds: ",$dnes,"\nCAST ROKU : $castroku\n";


## londeg lonmin   latdeg  latmin    h m s   $cdst=dayl.sav.t
  $SEC_IN_DAY=86400;  $J2000=2451545.;
  $DEG_IN_RADIAN=57.2957795130823;
  $HRS_IN_RADIAN=3.819718634205;
  $PI=3.14159265358979;

 $longitude=$longdir*($londeg + $lonmin/60);
 $latitude=$latdir*($latdeg + $latmin/60);






           #####kvuli ilum - 5
 $dtime=$h + $m/60+ ($s-10)/3600;
## print "$dtime <$h:$m:$s>\t";
 $tzone=&longcorr;
 $tzone=0; $degcorr=-$longitude;  # MY. no timezone?!?!?!  GMT!!!
 $jd=&date_to_jd; #print "Julian date: $jd\n";
 $lst=&calc_lst;

###############$lst=&adj_time($lst-18.4897);
###sun
 $a4=&lpsun;
 $alt_sun = alt($ra_sun,$dec_sun,$latitude);
 $az_sun = az($ra_sun,$dec_sun,$latitude);
#print "SUN: alt= $alt_sun  az=$az_sun\n";
 $a5=&lpmoon;
 $alt_moon = alt($ra_moon,$dec_moon,$latitude);
 $az_moon = az($ra_moon,$dec_moon,$latitude);
 $ill_frac=0.5*(1.-cos(&subtend($ra_moon,$dec_moon,$ra_sun,$dec_sun)));
#print "MOON: alt= $alt_moon  az=$az_moon  ill_fr=$ill_frac\n";
 $ill_frac_1st=$ill_frac;








####### druhe kolo kvuli illum frac;; -> chytrej, pricitam den????
 $dtime=$h + $m/60+ $s/3600;
#   print "$dtime";
 $tzone=&longcorr;
 $tzone=0; $degcorr=-$longitude;  # MY. no timezone?!?!?!  GMT!!!
 $jd=&date_to_jd; #print "Julian date: $jd\n";
 $lst=&calc_lst;

###############$lst=&adj_time($lst-18.4897);
###sun
 $a4=&lpsun;
 $alt_sun = alt($ra_sun,$dec_sun,$latitude);
 $az_sun = az($ra_sun,$dec_sun,$latitude);
#print "SUN: alt= $alt_sun  az=$az_sun\n";
 $a5=&lpmoon;
 $alt_moon = alt($ra_moon,$dec_moon,$latitude);
 $az_moon = az($ra_moon,$dec_moon,$latitude);
 $ill_frac=0.5*(1.-cos(&subtend($ra_moon,$dec_moon,$ra_sun,$dec_sun)));
#print "MOON: alt= $alt_moon  az=$az_moon  ill_fr=$ill_frac\n";

$skyazim=$castroku*360+($h*3600+$m*60)/24/3600*360;# pro hvezdnou oblohu v zime


#print "SKY: alt= ",90-$latitude,"  az=",$skyazim,"\n";
$moonnum=$ill_frac-$ill_frac_1st;
$moonnum=asin(  ($ill_frac-0.5)/0.5 )/0.2075+8.778;
if($ill_frac-$ill_frac_1st<0){$moonnum=30-$moonnum}else{$moonnum-=2}

$moonnum+=1; $moonnum=29 if($moonnum>29);
$moonnum=1 if($moonnum<1);
$moonnum=int($moonnum);

#  moonnum --->  numver of picture
#return ($alt_sun,$az_sun,$alt_moon,$az_moon,$latitude,$moonnum,$skyazim);

return ($alt_sun,$az_sun,$alt_moon,$az_moon,$ill_frac,$moonnum,$skyazim, $latitude);
}   # calculate 

################################################################3
################################################################3
################################################################3




$seco=$ARGV[0];
$latdeg=$ARGV[1]; 
$londeg=$ARGV[2];
#print "$seco; $latdeg; $londeg\n";

$h=`date -d   \@$seco +%H  -u`; chop($h);
$m=`date -d   \@$seco +%M  -u`;chop($m);
$s=`date -d   \@$seco +%S  -u`;chop($s);
$day=  `date -d  \@$seco +%d  -u`;chop($day);
$month=`date -d  \@$seco +%m  -u`;chop($month);
$year= `date -d  \@$seco +%Y  -u`;chop($year);
#print STDERR  "... $h:$m:$s $day.$month $year utc\n";
@a=&calculate($h,$m,$s,$day,$month,$year,$londeg,$latdeg);


if(  ($ARGV[3] % 2)==1 ){
#  printf("sun: alt/az  %6.2f/%7.2f ",$a[0],$a[1]);
  printf("  %7.2f  %7.2f ",$a[1],$a[0]);  # azimut # alt
}
if ($ARGV[3]>=2){
#  printf("moon:alt/az  %6.2f/%7.2f  %.2f",$a[2],$a[3],$a[4]);
  printf("%7.2f %7.2f  %.2f",$a[3],$a[2],$a[4]);
}
print "\n";

