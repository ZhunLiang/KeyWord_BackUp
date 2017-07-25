#!/bin/perl
#Input para
$Vc=$ARGV[0];
$Vb=$ARGV[1];
$Kmax=$ARGV[2];
$Kmin=$ARGV[3];
$IonPairNum=$ARGV[4];
$v0=$Vc/$Vb;
$v1=int ($v0+1);
#print "$Vb, $v0, $v1\n";
if($v1<=$v0*$Kmin){
    $VVb=$Vc*($Kmin+($Kmax-$Kmin)/2)/($v1+1);
}
elsif($v1>=$v0*$Kmax){
    $VVb=$Vc*($Kmax-($Kmax-$Kmin)/2)/$v1;
}
else{
    $VVb=$Vb;
}
#Get the Vb' that satified: Kmin< ceil(Vc/Vb)/(Vc/Vb) < Kmax;
#also, satified: Kmin< dc/db < Kmax;
$vv0=$Vc/$VVb;
$vv1=int($vv0+1);
#print "$VVb, $vv0 \n";
$NewPairNum=int($VVb/$Vb*$IonPairNum);
$DeletPairNum=$IonPairNum-$NewPairNum;
$NewVVb=$Vb*$NewPairNum/$IonPairNum;
$Newv0=$Vc/$NewVVb;
$Newv1=int($Newv0+1);
#print "$NewVVb, $Newv0 \n";
#print "$NewPairNum \n";
print "$DeletPairNum \n";
