#!/bin/perl
$Direction=$ARGV[0];
@Key_Words=("*.itp","*.gro","*.py","*.sh","*.mdp","*.top","*.txt");
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

sub Copy{
  chdir $_[0];
  my @files_temp=<{$Files}>;
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
@FILE = <{$Files}>;
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

# The next is output#
print "############\tRun Over. \n";
print "###########\tOUTPUT. \n";
if($PRINT==1){
  if($RUNCOPY==1){print "############\tMkdir and copy file. \n";}
  else {print "############\tDo not copy file. only show total folder number and/or folders. \n";}
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

print "############\tTotal files number: $File_Num. \n";
print "############\tTotal folder number: $Folder_Num. \n";
print "############\tEND. \n";

