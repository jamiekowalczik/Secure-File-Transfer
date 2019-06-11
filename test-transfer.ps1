$TransferResult = Invoke-SecureFileTransfer -Hostname "fileserver" -Username "root" -Password "rootpassword" -Direction get -Source "/data/*" -Destination "C:\data\"

$TransferResult | Out-String

#################

$TransferResult = Invoke-SecureFileTransfer -Hostname "fileserver" -Username "root" -SshPrivateKeyPath "C:\privatekey.ppk" -Direction "put" -Method "SCP" -Source "C:\data\*" -Destination "/upload/data/"

$TransferResult | Out-String
