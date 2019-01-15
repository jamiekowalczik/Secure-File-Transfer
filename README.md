Secure-File-Transfer folder should be put in your $env:PSModulePath
Otherwise import with Import-Module

ex.) Import-Module Secure-File-Transfer #

---

$TransferResult = Invoke-SecureFileTransfer -Hostname "fileserver" -Username "root" -Password "rootpassword" -Direction get -Source "/data/*" -Destination "C:\data\"

$TransferResult | Out-String
