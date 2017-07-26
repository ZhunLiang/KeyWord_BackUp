# KeyWord_BackUp
This code was written by perl at Linux. The aim is based the KeyWord in main.sh, create backup folder.

Type: perl main.sh $NeedBackupFolder. Then you can see a BACKUP/ folder in $NeedBackupFolder/.

You can change the BACKUP/ to other name by change the $BackName in main.sh.

You can change the Key Word by change the @Key_Words in main.sh.

You can change the maxmun loop number by change the $CountUp in main.sh or set it as very high value to make sure this code can backup all you files.

The $CountUp is to make sure this code won't run all the time if the code is wrong. Also, I am not very sure it won't be wrong, so you need test before.

Update main.sh at 10:26 26/07/2017

You can choose whether to copy files and mkdir backup folder or not by change the variable $RUNCOPY as 1(yes) or other(no).

You can choose to print all the folders name in your type folder, set $SHOWFOLDER as 1(yes) or other(no).

You can choose to whether to print the above by set the $PRINT as 1(yes) or other()no.

It will by print some information like the run time, total folders number, total files number.

