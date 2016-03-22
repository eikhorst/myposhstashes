. E:\disenza\scripts\parts\DBBackupToDBName_yyyyMMdd.ps1  -ExecutionPolicy RemoteSigned -force
. E:\disenza\scripts\parts\RestoreDBName_yyyyMMdd.ps1  -ExecutionPolicy RemoteSigned -force

## Backups are put in the default backup location, 
## for BM it is here when a07 is primary:  \\ctysql-a07\e$\DA\MSSQL.1\MSSQL\Backup
## This also removes yesterday's bak file also.


BackItUp -dbserver "ctysql-a07r" -catalog "ClientB_ETD_L1"
####---- Restore does not work right now, using the sql job
#RestoreToNewDB -dbserver "ctysql-a07r" -catalog "ClientB_ETD_L1"

#BackItUp -dbserver "ctysql-a07r" -catalog "aDTtest"
#RestoreToNewDB -dbserver "ctysql-a07r" -catalog "aDTtest"


#>> Add other backups by calling the same two lines above for another db cluster and db.
