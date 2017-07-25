#!/bin/perl
#Input para
$ChannelFile=$ARGV[0];
$BulkIonFile=$ARGV[1];
$ChannelLong=$ARGV[2];
$BulkIonTop =$ARGV[3];
$FirstIonAtom=$ARGV[4];
$SecondIonAtom=$ARGV[5];
@ChannelXYZ=split/\s+/,`tail -1 $ChannelFile`;
@ChannelXYZ[3]= $ChannelLong-0.2;
@BulkIonXYZ=split/\s+/,`tail -1 $BulkIonFile`;
for($i=0;$i<3;$i=$i+1){
    @InitNumXYZ[$i]=@ChannelXYZ[$i+1]/@BulkIonXYZ[$i+1];
    #print "@ChannelXYZ[$i+1] \t";
    #print "@BulkIonXYZ[$i+1] \t";
    #print "@InitNumXYZ[$i] \t";
}
#print "\n";
$Vc=@ChannelXYZ[1]*@ChannelXYZ[2]*@ChannelXYZ[3];
$Vb=@BulkIonXYZ[1]*@BulkIonXYZ[2]*@BulkIonXYZ[3];
$InitNum=$Vc/$Vb;
$NeedNum=int($InitNum+0.999999);
#print "$InitNum, $NeedNum \n";
for($i=0;$i<2;$i=$i+1){
    if(@InitNumXYZ[$i]<1){@TuneNumXYZ[$i]=1;}
    else {@TuneNumXYZ[$i]=int(@InitNumXYZ[$i]+0.5);}
    #print "@TuneNumXYZ[$i] \t";
}
@TuneNumXYZ[2]=$NeedNum/@TuneNumXYZ[0]/@TuneNumXYZ[1];
$Err=@TuneNumXYZ[2]-int(@TuneNumXYZ[2]);
if($Err!=0){
    @TuneNumXYZ[2]=int(@TuneNumXYZ[2])+1;
}
#@TuneNumXYZ[2]=int(@TuneNumXYZ[2]+0.999999);
#print "@TuneNumXYZ[2] \n";
$TuneTotalNum=@TuneNumXYZ[0]*@TuneNumXYZ[1]*@TuneNumXYZ[2];
$ErrNum=$TuneTotalNum-$NeedNum;
#print "$ErrNum \n";
for($i=0;$i<3;$i=$i+1){
    @ScaleXYZ[$i]=(@ChannelXYZ[$i+1]-0.2)/@TuneNumXYZ[$i];
    #print "@ScaleXYZ[$i] \t";
    @ScaleRatio[$i]=@ScaleXYZ[$i]/@BulkIonXYZ[$i+1];
    #print "@BulkIonXYZ[$i+1] \t";
    #print "@ScaleRatio[$i] \t";
}
#print "\n";
for($i=0;$i<3;$i=$i+1){
    if(@ScaleRatio[$i]<1){
        $temp=log (@ScaleRatio[$i])/log (0.95);
    }
    else {
        $temp=log (@ScaleRatio[$i])/log (1.05);        
    }
    @ScaleTime[$i] = int($temp+0.999999);
    if($i==0){
        $MaxTime=@ScaleTime[$i];
        $MaxIndex=$i;
    }
    elsif(@ScaleTime[$i]>=@ScaleTime[$i-1]){
        $MaxTime=@ScaleTime[$i];
        $MaxIndex=$i;
    }
}
#print "$MaxTime, $MaxIndex \n";
for($i=0;$i<$MaxTime;$i=$i+1){
    for($j=0;$j<3;$j=$j+1){
        if($i<@ScaleTime[$j]) {@ScaleValue[$MaxTime*$j+$i]=@ScaleRatio[$j]**(1/@ScaleTime[$j]); }
        else {@ScaleValue[$MaxTime*$j+$i]=1;}
        #print "@ScaleValue[$MaxTime*$j+$i] \t";
    }
    #print "\n";
}
#Start scale run
system "cp $BulkIonFile scale_end.gro";
for($i=0;$i<$MaxTime;$i=$i+1){
    system "mkdir scale";
    system "cp *.itp $BulkIonTop scale-nvt.mdp scale/";
    system "cp scale_end.gro scale/scale_start.gro";
    system "cd scale/;editconf -f scale_start.gro -scale @ScaleValue[0+$i] @ScaleValue[$MaxTime+$i] @ScaleValue[$MaxTime*2+$i] -o scale_start.gro";
    system "cd scale/;grompp -f scale-nvt.mdp -c scale_start.gro -p $BulkIonTop -o scale_end.tpr;mdrun -s scale_end.tpr -v -deffnm scale_end -pin on";
    system "cd scale/;echo 0 | trjconv -s scale_end.tpr -f scale_end.gro -pbc mol -o scale_end2.gro";
    system "mv scale/scale_end2.gro ./scale_end.gro; rm -rf scale/";
}

#print "@TuneNumXYZ[0] @TuneNumXYZ[1] @TuneNumXYZ[2] $NeedNum $FirstIonAtom $SecondIonAtom \n";
system "perl Ion_channel.sh scale_end.gro tune_end.top @TuneNumXYZ[0] @TuneNumXYZ[1] @TuneNumXYZ[2] $NeedNum $FirstIonAtom $SecondIonAtom";
system "rm scale_end.* tune_end.*";
