. .\Secure-File-Transfer

$DebugScript = $true
$TransferResult = Secure-File-Transfer -Hostname "fileserver" -Username "root" -Password "rootpassword" -Direction get -Source "/data/*" -Destination "C:\data\"
$TransferResult | Out-String