#!/bin/perl
$Direction=$ARGV[0];
@Key_Words=("*.itp","*.gro","*.py","*.sh","*.mdp","*.top","*.txt");
$Files = join(",",@Key_Words);
#@Folder = ("");
$CountUp = 3;#maxmun loop number
$BackName = "BACKUP"; #Total backup folder name

sub BackupPrefix{
  my $last=substr($_[0],-1,1); 
  if($last eq "/"){$temp = "$Direction$BackName";}
  else{$temp = "$Direction/$BackName";}
  return $temp;
}

sub Copy{
  chdir $_[0];
  my @files_temp=<{$Files}>;
  #print "$_[0]\n";
  #my $BackFolder="$Direction/BACKUP/$_[0]";
  my $BackFolder = "$Prefix/$_[0]";
  print "$BackFolder\n";
  #mkdir($BackFolder) unless(-d $BackFolder);
  #if(@files_temp){system "cp -f @files_temp $BackFolder";}
  #chdir $Direction;
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
mkdir($BackName) unless(-d $BackName);
system "cp -f @FILE $BackName";
SaveFolder(@FOLDER);
push @FolderRun,@FOLDER;

$RunNum = @FolderRun;
$COUNT=0;
#print "$RunNum\n";
while($RunNum!=0 && $COUNT<$CountUp){
  #print "before shift, @FolderRun\n";
  #$RunNum = @FolderRun;
  #print "before shift num, $RunNum\n";
  $Folder_temp = shift @FolderRun;
  $COUNT += 1;
  Copy($Folder_temp);
  #print "after shift, folder, @FolderRun\n";
  #print "shift, count, $COUNT\n";
  $RunNum = @FolderRun;
  #print "after shift, num, $RunNum\n";
  @Temp = GetFolder($Folder_temp);
  if(@Temp){
    SaveFolder(@Temp);
    $RunNum = @FolderRun;
    #print "before push, @FolderRun\n";
    #print "before push num, $RunNum\n";
    @FolderRun = (@FolderRun,@Temp);
    $RunNum = @FolderRun;
    $COUNT += 1;
    #print "after push, folder, @FolderRun\n";
    #print "push, count, $COUNT\n";
    #print "after push, num, $RunNum\n";
  }
}

print "Output\n@Folder\n";
#$OutNum = @Folder;
#print "Folder num, $OutNum\n";
#print "@FolderRun\n";



#foreach $Folder(@Folder){
#  Copy($Folder);
#}
