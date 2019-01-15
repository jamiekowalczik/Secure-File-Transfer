# Secure-File-Transfer

## Secure-File-Transfer folder should be put in your $env:PSModulePath
Import-Module Secure-File-Transfer

$TransferResult = Invoke-SecureFileTransfer -Hostname "fileserver" -Username "root" -Password "rootpassword" -Direction get -Source "/data/*" -Destination "C:\data\"

$TransferResult | Out-String