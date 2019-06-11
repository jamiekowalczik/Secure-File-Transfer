<#
.SYNOPSIS
A set of functions for dealing with SFTP/SCP connections from PowerShell, using the WinSCPnet
library found here on: http://winscp.net/eng/docs/library_install

Author: Jamie Kowalczik

.DESCRIPTION
See:
Get-Help Invoke-SecureFileTransfer
#>

<#
   .SYNOPSIS
      This will securely get or retrieve files using the sftp or scp protocol.

   .DESCRIPTION
      This function will securely retrieve files using the sftp or scp protocol.  
      Optionally you can specify a server's fingerprint to be verified prior to sending files.

   .EXAMPLE
      Invoke-SecureFileTransfer -Hostname "fileserver" -Username "usera" -Password "passworda" -Direction "put" -Source "C:\data\*" -Destination "/upload/data/"

   .EXAMPLE
      Invoke-SecureFileTransfer -Hostname "fileserver" -Username "usera" -Password "passworda" -Direction "put" -Method "SCP" -Fingerprint "rsa-2048 xxxxxxxxxxxx" -Source "C:\data\*" -Destination "/upload/data/"
 
   .EXAMPLE
      Invoke-SecureFileTransfer -Hostname "fileserver" -Username "usera" -SshPrivateKeyPath "C:\privatekey.ppk" -Direction "put" -Method "SCP" -Fingerprint "rsa-2048 xxxxxxxxxxxx" -Source "C:\data\*" -Destination "/upload/data/"

   .NOTES
      For this function to work you must reference the WinSCP Library.  The function will send files using sftp or scp, defaulting to sftp.  
      Supplying a server's fingerprint is optional.

   .LINK
      http://winscp.net/eng/docs/library_install
#>

Function Invoke-SecureFileTransfer{
   [CmdletBinding()]
   Param(
      # The remote server's IP address or FQDN
      [Parameter(Mandatory=$true)][String]$Hostname,
      # The username to login to the remote server with
      [Parameter(Mandatory=$true)][String]$Username,
      # The password to login to the remote server
      [Parameter(Mandatory=$false)][String]$Password,
	  # The private key to login to the remote server
      [Parameter(Mandatory=$false)][String]$SshPrivateKeyPath,
      # The direction for the file transfer - GET or PUT
      [Parameter(Mandatory=$true)][String]$Direction = "",
      # The protocol to use for file transfer - SFTP or SCP
      [String]$Method = "SFTP",
      # The remote server's fingerprint.  This paramter is optional
      [String]$Fingerprint,
      # The source file or directory for the transfer
      [Parameter(Mandatory=$true)][String]$Source,
      # The destination file or directory for the transfer
      [Parameter(Mandatory=$true)][String]$Destination,
      # If set to True then debugging information will be displayed to the user
      [Bool]$DebugFunction = $false
   )

   Try{  
      If($DebugFunction){
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
	  $sessionOptions.SshPrivateKeyPath=$SshPrivateKeyPath

   
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
   }Catch{
      Write-Host $_.Exception.Message
   }
}

######## END OF FUNCTIONS ########

Export-ModuleMember -Function Invoke-SecureFileTransfer
