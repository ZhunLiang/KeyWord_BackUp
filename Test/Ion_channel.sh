#!/bin/perl
#Input para
$IonFile=$ARGV[0];
$IonTop =$ARGV[1];
$Xnum=$ARGV[2];
$Ynum=$ARGV[3];
$Znum=$ARGV[4];
$NeedNum=$ARGV[5];
$FirstIonAtom=$ARGV[6];
$SecondIonAtom=$ARGV[7];
@IonXYZ=split/\s+/,`tail -1 $IonFile`;
@IonPair=split/\s+/,`tail -1 $IonTop`;
$IonPairNum=@IonPair[1];
$NeedPairNum=$IonPairNum*$NeedNum;
$RealPairNum=$IonPairNum*$Xnum*$Ynum*$Znum;
$DeletePairNum=$RealPairNum-$NeedPairNum;
system "genconf -f $IonFile -nbox $Xnum $Ynum $Znum -o IonMulti.gro";
if($DeletePairNum!=0){ 
     system "/opt/python/bin/python ~/bin/DelMole.py -i IonMulti.gro -F $FirstIonAtom -S $SecondIonAtom -n $RealPairNum -d $DeletePairNum -o IonMultiDel.gro ";
     system "rm IonMulti.gro";
}
else { system "mv IonMulti.gro IonMultiDel.gro";}
system "cp $IonTop IonMultiDel.top";
#system "cp $IonTop IonMultiDel2.top";
#print "$IonPairNum, $RealPairNum \n";
system "sed -i 's/$IonPairNum/$NeedPairNum/g' IonMultiDel.top";
#print "$IonPairNum, $NeedPairNum \n";
system "/opt/python/bin/python ~/bin/SortMole.py -i IonMultiDel.gro -F $FirstIonAtom -S $SecondIonAtom -s $IonPairNum -t $NeedPairNum -o temp.gro";
system "mv temp.gro IonMultiDel.gro";
system "mkdir IonMulti/;";
system "cp *.itp scale-nvt.mdp IonMulti/;mv IonMultiDel.gro IonMultiDel.top IonMulti/";
system "cd IonMulti/;grompp -f scale-nvt.mdp -c IonMultiDel.gro -p IonMultiDel.top -o IonMulti.tpr;mdrun -s IonMulti.tpr -v -deffnm IonChannel -pin on";
system "cd IonMulti/;echo 0 | trjconv -f IonChannel.gro -s IonMulti.tpr -pbc mol -o IonChannel2.gro";
system "mv IonMulti/IonMultiDel.top ./IonChannel.top; mv IonMulti/IonChannel2.gro ./IonChannel.gro";
system "rm -rf IonMulti/";
system "mkdir scale_multi";
system "cp *.itp scale-nvt.mdp IonChannel.top scale_multi/; mv IonChannel.gro scale_multi/";
system "cd scale_multi/;editconf -f IonChannel.gro -scale 0.95 0.95 0.9 -o temp.gro";
system "cd scale_multi/;grompp -f scale-nvt.mdp -c temp.gro -p IonChannel.top -o temp.tpr;mdrun -s temp.tpr -v -deffnm end -ntmpi 1 -ntomp 32 -pin on";
system "cd scale_multi/;echo 0 | trjconv -f end.gro -s temp.tpr -pbc mol -o temp-end.gro;mv temp-end.gro ../IonChannel.gro";
system "rm -rf scale_multi/";
