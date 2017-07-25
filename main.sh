#!/bin/perl
$Direction=$ARGV[0];
@Key_Words=("*.itp","*.gro","*.py","*.sh","*.mdp","*.top","*.txt");
$Files = join(",",@Key_Words);
$CountUp = 30;
$BackName = "BACKUP";

sub BackupPrefix{
  my $last=substr($_[0],-1,1); 
  if($last eq "/"){$temp = "$Direction$BackName";}
  else{$temp = "$Direction/$BackName";}
  return $temp;
}

sub Copy{
  chdir $_[0];
  my @files_temp=<{$Files}>;
  my $BackFolder = "$Prefix/$_[0]";
  mkdir($BackFolder) unless(-d $BackFolder);
  if(@files_temp){system "cp -f @files_temp $BackFolder";}
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
mkdir($BackName) unless(-d $BackName);
system "cp -f @FILE $BackName";
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

print "Output\n@Folder\n";
