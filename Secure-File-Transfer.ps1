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
      This will securely retrieve files using the sftp or scp protocol.

   .DESCRIPTION
      This function will securely retrieve files using the sftp or scp protocol.  
      Optionally you can specify a server's fingerprint to be verified prior to sending files.

   .EXAMPLE
      Get-Files -Username "usera" -Password "passworda" -Source "C:\data\*" -Destination "/upload/data/"

   .EXAMPLE
      Get-Files -Username "usera" -Password "passworda" -Method "SCP" -Fingerprint "rsa-2048 xxxxxxxxxxxx" -Source "C:\data\*" -Destination "/upload/data/"

   .NOTES
      For this function to work you must reference the WinSCP Library.  The function will send files using sftp or scp, defaulting to sftp.  
      Supplying a server's fingerprint is optional.

   .LINK
      http://winscp.net/eng/docs/library_install
#>
Function Get-Files{
   [CmdletBinding()]
   Param(
      # The remote server's IP address or FQDN
      [String]$Hostname,
      # The username to login to the remote server with
      [String]$Username,
      # The password to login to the remote server
      [String]$Password,
      # The protocol to use for file transfer - SFTP or SCP
      [String]$Method = "SFTP",
      # The remote server's fingerprint.  This paramter is optional
      [String]$Fingerprint,
      # The source file or directory for the transfer
      [String]$Source,
      # The destination file or directory for the transfer
      [String]$Destination
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
 
   $transferResult = $session.GetFiles($Source, $Destination, $False, $transferOptions)
 
   $transferResult.Check()

   $session.Dispose()

   Return $transferResult
}
<#
   .SYNOPSIS
      This will securely transfer files using the sftp or scp protocol.

   .DESCRIPTION
      Put-Files will securely transfer files using the sftp or scp protocol.  
      Optionally you can specify a server's fingerprint to be verified prior to sending files.

   .EXAMPLE
      Put-Files -Username "usera" -Password "passworda" -Source "C:\data\*" -Destination "/upload/data/"

   .EXAMPLE
      Put-Files -Username "usera" -Password "passworda" -Method "SCP" -Fingerprint "rsa-2048 xxxxxxxxxxxx" -Source "C:\data\*" -Destination "/upload/data/"

   .NOTES
      For this function to work you must reference the WinSCP Library.  The function will send files using sftp or scp, defaulting to sftp.  
      Supplying a server's fingerprint is optional.

   .LINK
      http://winscp.net/eng/docs/library_install
#>
Function Put-Files{
   [CmdletBinding()]
   Param(
      # The remote server's IP address or FQDN
      [String]$Hostname,
      # The username to login to the remote server with
      [String]$Username,
      # The password to login to the remote server
      [String]$Password,
      # The protocol to use for file transfer - SFTP or SCP
      [String]$Method = "SFTP",
      # The remote server's fingerprint.  This paramter is optional
      [String]$Fingerprint,
      # The source file or directory for the transfer
      [String]$Source,
      # The destination file or directory for the transfer
      [String]$Destination
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
 
   $transferResult = $session.PutFiles($Source, $Destination, $False, $transferOptions)
 
   $transferResult.Check()

   $session.Dispose()

   Return $transferResult
}
