#!/bin/perl
$Direction=$ARGV[0];
#@Key_Words=("*INCAR*","*KPOINTS*","*POSCAR*","*CONTCAR*","*.vasp","*.cif");
#@Key_Words=("*.itp","*.gro","*.py","*.sh","*.mdp","*.top","*.txt","*.m","*.c","*.xvg","*.ndx","*.pbs","*.tpr");
@Key_Words=("*INCAR*","*POTCAR*","*POSCAR","*KPOINTS*","*.vasp","*.cif","*.itp","*.gro","*.py","*.sh","*.mdp","*.top","*.txt","*.dat","*.m","*.c","*.xvg","*.ndx","*.pbs","*.tpr");
#@Key_Words=("*.itp");
@NotKey=(densMNC,trr);
$Files = join(",",@Key_Words);
$File_Num = 0;
$CountUp = 3000;
$BackName = "BACKUP";
#Control copy and print. Only = 1, do copy or print.
$PRINT = 1;
$RUNCOPY = 0;
$SHOWFOLDER = 0;

sub CountFile{
  my $temp = @_;
  $File_Num = $File_Num + $temp;
}

sub BackupPrefix{
  my $last=substr($_[0],-1,1); 
  if($last eq "/"){$temp = "$Direction$BackName";}
  else{$temp = "$Direction/$BackName";}
  return $temp;
}

sub GetFile{
  my @temp = @_;
  foreach $NotKey(@NotKey){
    @temp = grep !/$NotKey/,@temp;
  }
  return @temp;
}

sub Copy{
  chdir $_[0];
  my @files_temp=<{$Files}>;
  @files_temp = GetFile(@files_temp);
  CountFile(@files_temp);
  my $BackFolder = "$Prefix/$_[0]";
  if($RUNCOPY==1){
    mkdir($BackFolder) unless(-d $BackFolder);
    if(@files_temp){system "cp -f @files_temp $BackFolder";}
  }
  chdir $Direction;
}

sub SaveFolder{
  if(@_){
    push @Folder,@_;
  }
}

sub GetFolder{
  my @temp;
  if($_[0]){
    chdir $_[0];
    @folder=<{*/}>;
    foreach $folder(@folder){
      @temp = (@temp,"$_[0]$folder");
    }
    chdir $Direction;
  }
  return @temp;
}

$Prefix = BackupPrefix($Direction);
chdir $Direction;
@FOLDER = <{*/}>;
@FOLDER = grep !/$BackName/,@FOLDER;
@FILE = <{$Files}>;
@FILE = GetFile(@FILE);
if($RUNCOPY==1){
  mkdir($BackName) unless(-d $BackName);
  if(@FILE){system "cp -f @FILE $BackName";}
}
CountFile(@FILE);
SaveFolder(@FOLDER);
push @FolderRun,@FOLDER;

$RunNum = @FolderRun;
$COUNT=0;
while($RunNum!=0 && $COUNT<$CountUp){
  $Folder_temp = shift @FolderRun;
  $COUNT += 1;
  Copy($Folder_temp);
  $RunNum = @FolderRun;
  @Temp = GetFolder($Folder_temp);
  if(@Temp){
    SaveFolder(@Temp);
    $RunNum = @FolderRun;
    @FolderRun = (@FolderRun,@Temp);
    $RunNum = @FolderRun;
  }
}
$Folder_Num = @Folder;
#if($RUNCOPY){system "mv $BackName ../";}

# The next is output#
print "############\tRun Over. \n";
print "###########\tOUTPUT. \n";
if($PRINT==1){
  if($RUNCOPY==1){print "############\tMkdir and copy file. \n";}
  else {print "############\tDo not copy file. Only show total folder number and/or folders. \n";}
  if($SHOWFOLDER==1){
    print "############\tShow Folders.\n";
    for($i=0;$i<$Folder_Num;$i=$i+1){
      if(($i+1) % 3 == 0){print "@Folder[$i]\n";}
      elsif(($i+1) % 3 == 1){print "####  @Folder[$i]\t";}
      else{print "@Folder[$i]\t";}
    }
    print "\n";
  }
}

print "############\tTotal folders number: $Folder_Num. \n";
print "############\tTotal files number: $File_Num. \n";
print "############\tEND. \n";

