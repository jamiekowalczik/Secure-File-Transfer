Param(
   [String]$PreReqModuleFile = ".\Modules\winscp556automation\WinSCPnet.dll",
   [Bool]$DebugScript = $false
)

Try{
   Add-Type -Path $PreReqModuleFile
}Catch{
   Write-Host $_.Exception.Message
   Write-Host $_.Exception.ItemName
   Write-Host "The module can be downloaded from: http://winscp.net/eng/docs/library_install"
   Exit 1
}

<#
   .SYNOPSIS
      This will securely get or retrieve files using the sftp or scp protocol.

   .DESCRIPTION
      This function will securely retrieve files using the sftp or scp protocol.  
      Optionally you can specify a server's fingerprint to be verified prior to sending files.

   .EXAMPLE
      Secure-File-Transfer -Hostname "fileserver" -Username "usera" -Password "passworda" -Direction "put" -Source "C:\data\*" -Destination "/upload/data/"

   .EXAMPLE
      Secure-File-Transfer -Hostname "fileserver" -Username "usera" -Password "passworda" -Direction "put" -Method "SCP" -Fingerprint "rsa-2048 xxxxxxxxxxxx" -Source "C:\data\*" -Destination "/upload/data/"

   .NOTES
      For this function to work you must reference the WinSCP Library.  The function will send files using sftp or scp, defaulting to sftp.  
      Supplying a server's fingerprint is optional.

   .LINK
      http://winscp.net/eng/docs/library_install
#>
Function Secure-File-Transfer{
   [CmdletBinding()]
   Param(
      # The remote server's IP address or FQDN
      [Parameter(Mandatory=$true)][String]$Hostname,
      # The username to login to the remote server with
      [Parameter(Mandatory=$true)][String]$Username,
      # The password to login to the remote server
      [Parameter(Mandatory=$true)][String]$Password,
      # The direction for the file transfer - GET or PUT
      [Parameter(Mandatory=$true)][String]$Direction = "",
      # The protocol to use for file transfer - SFTP or SCP
      [String]$Method = "SFTP",
      # The remote server's fingerprint.  This paramter is optional
      [String]$Fingerprint,
      # The source file or directory for the transfer
      [Parameter(Mandatory=$true)][String]$Source,
      # The destination file or directory for the transfer
      [Parameter(Mandatory=$true)][String]$Destination
   )
  
   If($DebugScript){
      $CommandName = $PSCmdlet.MyInvocation.InvocationName;
      # Get the list of parameters for the command
      $ParameterList = (Get-Command -Name $CommandName).Parameters;
      $now = Get-Date; Write-Host "`n$($MyInvocation.MyCommand.Name):: started $now"
      # Grab each parameter value, using Get-Variable
	  $FunctionVariables = ""
      foreach ($Parameter in $ParameterList) {
         $FunctionVariables = Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue | Out-String
      }
	 Write-Host "$FunctionVariables"
   }

   # Configure the sessions options.  
   $sessionOptions = New-Object WinSCP.SessionOptions

   # If a transfer method is not specified then default to SFTP.
   switch ($Method) {
      "sftp" {
         $sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
         break
      }
      "scp" {
         $sessionOptions.Protocol = [WinSCP.Protocol]::Scp
         break
      }
      default {
         $sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
         break
      }
   }
   
   # If a fingerprint is not specified then turn of hostkey checking
   If($Fingerprint -eq ""){ $sessionOptions.GiveUpSecurityAndAcceptAnySshHostKey = $true } Else { $sessionOptions.SshHostKeyFingerprint = $Fingerprint }

   $sessionOptions.HostName = $Hostname
   $sessionOptions.UserName = $Username
   $sessionOptions.Password = $Password
   
   $session = New-Object WinSCP.Session
   $session.Open($sessionOptions)

   $transferOptions = New-Object WinSCP.TransferOptions
   $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

   # Determine whether to put or get
   switch ($Direction) {
      "put" {
         $transferResult = $session.PutFiles($Source, $Destination, $False, $transferOptions)
         break
      }
      "get" {
         $transferResult = $session.GetFiles($Source, $Destination, $False, $transferOptions)
         break
      }
      default {
         Write-Host "Invalid direction specified.  Please use PUT or GET"
         Exit 1
         break
      }
   }
 
   $transferResult.Check()

   $session.Dispose()

   Return $transferResult
}