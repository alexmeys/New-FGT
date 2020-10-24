#region Script header
#requires -version 5
<#
.SYNOPSIS
  PowerShell script to configure a Fortigate (Fortinet) Firewall unit. Tested on FGT v5.2.0 / v6.2.3
.DESCRIPTION
  This script is intended for new Fortigate unit's. An easy way to install them from scratch.
  However it can change an active Fortigate firewall aswell. Keep in mind to always make a backup first, just in case.
  This script relies on SSH access, so if you connect from a lan port, enable SSH on the interface. 
  If you connect remote, enable SSH on the WAN and add trusted IP's, this to prevent unwanted SSH access.
.OUTPUTS
  No
.NOTES
  Version:        1.0
  Author:         Alex Meys
  Creation Date:  24/10/2020
  Purpose/Change: Initial Automated Fortigate preparation script
  
.EXAMPLE
  Not Supplied, just run the .\FGT_Start script and you will get the menu.
#>
#endregion

#region Connect to FGT Unit

Import-Module $PSScriptRoot\FGT_Ssh.psm1
$Sess = New-FGTInit

#endregion

#region Main menu loop

do
{
    # Clear previous screens
    # set variable again to 'yes' so it continues to loop until user decides otherwise.
    # Set extra line, to prevent too fast switching and colors mixing up.

    Clear-Host
    $again = "y"
    Start-Sleep -Milliseconds 10

    Write-Host "`n*** Menu ***`n" -ForegroundColor Green
    Write-Host "1) Set Generic Information"
    Write-Host "2) Set LAN/DHCP"
    Write-Host "3) Set DNS"
    Write-Host "4) Set WAN"
    Write-Host "5) Policy (+UTM)"
    Write-Host "6) Disable ALG"
    Write-Host "7) Reboot or Shutdown Unit"
    Write-Host "`n************" -ForegroundColor Green

    $OptChs = Read-Host -Prompt "`nChoose an option (exit to leave)"

    switch ($OptChs)
        {
            default 
            {
                Remove-Module FGT_* -ErrorAction SilentlyContinue
                Write-Host "... exiting now ..." -ForegroundColor Red
                exit 0
            }
            1
            {
                Import-Module $PSScriptRoot\FGT_Info.psm1
                Set-FGTInfo $Sess
                Remove-Module FGT_Info -ErrorAction SilentlyContinue   
            }
            2
            {  
                Import-Module $PSScriptRoot\FGT_Lan.psm1
                Set-FGTLan $Sess
                Remove-Module FGT_Lan -ErrorAction SilentlyContinue
            }
            3
            {
                Import-Module $PSScriptRoot\FGT_Dns.psm1
                Set-FGTDns $Sess
                Remove-Module FGT_Dns -ErrorAction SilentlyContinue
            }
            4
            {
                Import-Module $PSScriptRoot\FGT_Wan.psm1
                Set-FGTWan $Sess
                Remove-Module FGT_Wan -ErrorAction SilentlyContinue
            }
            5
            {
                Import-Module $PSScriptRoot\FGT_Policy.psm1
                Set-FGTPolicy $Sess
                Remove-Module FGT_Policy -ErrorAction SilentlyContinue   
            }
            6
            {
                Import-Module $PSScriptRoot\FGT_Alg.psm1
                Set-FGTAlg $Sess
                Remove-Module FGT_Alg -ErrorAction SilentlyContinue
            }
            7
            {
                Import-Module $PSScriptRoot\FGT_Off.psm1
                Set-FGTOff $Sess
                Remove-Module FGT_Off -ErrorAction SilentlyContinue
            }
        }

} while (($again -eq "y"))

#Closing open SSH Session and exiting.
Remove-FGTSsh
Remove-Module FGT_Ssh -ErrorAction SilentlyContinue
Remove-Module FGT_* -ErrorAction SilentlyContinue
Write-Host "... exiting now ...`n" -ForegroundColor Red
exit 0
#endregion

#region todo
# Maybe thinking about adding VLAN integration in a separate module, but have to redo some code to factor in policy's etc
# No time now, but maybe one day...
#endregion