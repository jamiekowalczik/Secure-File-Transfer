. .\Secure-File-Transfer

$DebugScript = $true
$TransferResult = Get-Files -Hostname "fileserver" -Username "root" -Password "rootpassword" -Source "/data/*" -Destination "C:\data\"
$TransferResult | Out-String