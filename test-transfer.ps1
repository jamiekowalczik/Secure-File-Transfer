$TransferResult = Invoke-SecureFileTransfer -Hostname "fileserver" -Username "root" -Password "rootpassword" -Direction get -Source "/data/*" -Destination "C:\data\"

$TransferResult | Out-String