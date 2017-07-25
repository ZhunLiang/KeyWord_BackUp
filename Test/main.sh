#!/bin/perl
#INPUT
$file=$ARGV[0]; #SingleWall.gro
$channel_topfile=$ARGV[1];  #SingleWall.top
$IonFile=$ARGV[2]; #bulk npt equilibrated at same temperature with wanted channel temperature.
$IonTop=$ARGV[3]; # the ion gro file corresponding top file
$OutWallTop=$ARGV[4];
$OutPutChannel=$ARGV[5];
@WantedXYZ= (5,5,-1);
$ChannelLong=8;
$TotalZLong=30;
@GroNum= (0,0,0);
@ScaleSize= (0,0,1);
$channel_grofile="Ti3C2-ele.gro";
$channel_name="Ti3C2_ele";
$scale_size=100; #scale size means the decimal point number, 100 means %.2f, 1000 means %.3f
$FirstAtomNum=19; #the fisrt mole type of IonFile atom number
$SecondAtomNum=15; # teh second
$Kmax=1.1; #the maxmiun density of channel ion compare with bulk
$Kmin=1.02; #the mimnium density of channel ion compare with bulk
@MoleName=("TiC","Emi","f2N"); #molecular name corresponding top file and gro file.
#
@GroXYZ= split/\s+/,`tail -1 $file`; #GroXYZ[1] [2] [3] is X, Y, Z
#Get the Input gri box size: X, Y, Z
for ($i=0; $i<3; $i=$i+1){
    $temp = @WantedXYZ[$i]/@GroXYZ[$i+1];
    @GroNum[$i] = int($temp);
    if (@GroNum[$i]<=0){
        @GroNum[$i]=1;
    }
}
#Get the needed nbox number
system "genconf -f $file -nbox @GroNum[0] @GroNum[1] @GroNum[2] -o temp_out.gro";
@TempXYZ= split/\s+/, `tail -1 temp_out.gro`; #[1],[2],[3] is X,Y,Z
for ($i=0; $i<2; $i=$i+1){
    $temp=@TempXYZ[$i+1]*$scale_size;
    $temp=sprintf "%.0f", $temp;
    $temp_scale=$temp/$scale_size/@TempXYZ[$i+1]; #charge 100, charge the new gro X, Y size. 100 means %.2f
    @ScaleSize[$i]=$temp_scale;
}
system "editconf -f temp_out.gro -scale @ScaleSize[0] @ScaleSize[1] 1 -o tempLeft.gro \n";
@NewGroXYZ=split/\s+/, `tail -1 tempLeft.gro`; #Get the scaled box size: X, Y, Z
system "rm -f temp_out.gro";
#Get the scaled gro, the x,y,z is %.3f format
system "/opt/python/bin/python ~/bin/GetZmax.py -i tempLeft.gro > LPyOut";
@ZLMaxMin= split/\s+/,`cat LPyOut`; #Get the LeftGro Zmax[0] and Zmin[1]
system "editconf -f tempLeft.gro -scale 1 1 -1 -o tempRight.gro";
system "/opt/python/bin/python ~/bin/GetZmax.py -i tempRight.gro > RPyOut";
@ZRMaxMin=split/\s+/,`cat RPyOut`; #Get the RightGro Zmax[0] and Zmin[1]
$Ztrans=@ZLMaxMin[0]-@ZRMaxMin[1]+$ChannelLong; 
system "editconf -f tempRight.gro -translate 0 0 $Ztrans -o tempRightT.gro";
#Translate the left gro as right gro
@NewGroXYZ[3]=$TotalZLong;
system "/opt/python/bin/python ~/bin/CombineGro.py -l tempLeft.gro -r tempRightT.gro -n $channel_name -x @NewGroXYZ[1] -y @NewGroXYZ[2] -z @NewGroXYZ[3] -o output_temp1.gro";
#Combine these two gro as one total gro
system "editconf -f output_temp1.gro -c -o $channel_grofile";
@SingleWallNum=split/\s+/,`grep -w @MoleName[0] $channel_topfile`;
$NewWallNum=@SingleWallNum[1]*@GroNum[0]*@GroNum[1]*@GroNum[2]*2;
$match="@MoleName[0]\\s\\+\\([0-9]\\+\\)";
$replace="@MoleName[0]\\t$NewWallNum";
#print "$NewWallNum\t$match\t$replace\n";
system "rm -f tempLeft.gro tempRight.gro LPyOut RPyOut tempRightT.gro output_temp1.gro";
system "sed 's/$match/$replace/g' $channel_topfile > $OutWallTop";

#The next is to scale given IonFile(gro) to copy the coordinate to channel.
@IonBoxXYZ=split/\s+/,`tail -1 $IonFile`;
for ($i=0;$i<3;$i=$i+1){
    if ($i<2){
        @IdeaScaleSize[$i]=@NewGroXYZ[$i+1]/@IonBoxXYZ[$i+1];
    }
    else{
        @IdeaScaleSize[$i]=$ChannelLong/@IonBoxXYZ[$i+1];
    }
   # print "@IdeaScaleSize[$i] \n";
}
$NewGroIonV=@NewGroXYZ[1]*@NewGroXYZ[2]*($ChannelLong-0.2); #0.2 means the surface 0.1 nm each side don't have ion
$IonV=@IonBoxXYZ[1]*@IonBoxXYZ[2]*@IonBoxXYZ[3];
@IonPairNum=split/\s+/,`tail -1 $IonTop`;
system "perl tune_bulk.sh $NewGroIonV $IonV $Kmax $Kmin @IonPairNum[1] > Tune_Out";
$DeletPairNum=int(`cat Tune_Out`);
#print "$NewIonPair \n";
system "rm Tune_Out";
if($DeletPairNum!=0){
     $tune_gro="tune.gro";
     $tune_top="tune.top";
     system "/opt/python/bin/python ~/bin/DelMole.py -i $IonFile -F $FirstAtomNum -S $SecondAtomNum -n @IonPairNum[1] -d $DeletPairNum -o $tune_gro";
     $temp=@IonPairNum[1]-$DeletPairNum;
     system "cp $IonTop $tune_top";
     system "sed -i 's/@IonPairNum[1]/$temp/g' $tune_top";
     system "mkdir tune_bulk; cp *.itp tune_npt.mdp tune_bulk/; mv $tune_gro $tune_top tune_bulk/";
     system "cd tune_bulk/; grompp -f tune_npt.mdp -c $tune_gro -p $tune_top -o tune.tpr; mdrun -s tune.tpr -v -deffnm tune_end -pin on";
     system "mv tune_bulk/tune_end.gro ./;cp tune_bulk/$tune_top ./tune_end.top; rm -rf tune_bulk";
}
#
system "perl scale_bulk.sh $channel_grofile tune_end.gro $ChannelLong tune_end.top $FirstAtomNum $SecondAtomNum";
##above output: IonChannel.gro and IonChannel.top
#The Next is to copy the channel ion to electrode gro
@IonChannelXYZ=split/\s+/,`tail -1 IonChannel.gro`;
@IonTrans[0]=(@NewGroXYZ[1]-@IonChannelXYZ[1])/2;
@IonTrans[1]=(@NewGroXYZ[2]-@IonChannelXYZ[2])/2;
@IonTrans[2]=$TotalZLong/2-$ChannelLong/2+($ChannelLong-@IonChannelXYZ[3])/2;
system "editconf -f IonChannel.gro -translate @IonTrans[0] @IonTrans[1] @IonTrans[2] -o IonTemp.gro";
system "/opt/python/bin/python ~/bin/CombineGro.py -l $channel_grofile -r IonTemp.gro -n EminTf2N_Ti3C2 -x @NewGroXYZ[1] -y @NewGroXYZ[2] -z @NewGroXYZ[3] -o $OutPutChannel";
system "rm -f IonTemp.gro";
#print "@IonTrans[2] \n";
system "rm -f IonChannel.gro $channel_grofile";
