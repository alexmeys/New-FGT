#region for disabling ALG
 
function Set-FGTAlg
{
    param(
    [parameter(Mandatory=$true)]
    $Session
    )
        
    # Menu
    $SbName = '{0}' -f $MyInvocation.MyCommand
    $SbName = $SbName.TrimStart("Set-FGT")

    Import-Module $PSScriptRoot\FGT_SubMenu.psm1
    Read-Submenu $SbName
    if($Global:answSub -eq 1){clear-Host}
    else{return}
    Remove-Module FGT_SubMenu -ErrorAction SilentlyContinue
    #End Menu

    #Enable/Disable ALG
    Write-Host "`n*** Disabling ALG ***`n" -ForegroundColor Green

    $AlgCertain = Read-Host -Prompt "Are you certain you want to disable ALG (y/n)?"

    if($AlgCertain -ne 'y'){return}

    $SSH1 = New-SSHShellStream -Index $Session.SessionId

    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config system console")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set output standard")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config system session-helper")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("show")
    Start-SLeep -Milliseconds 300
    $ReadSession = $SSH1.Read()

    # Find the SIP ID number (if any)
    $ReadSession -split '\r?\n' | Select-String -Pattern "next" -Context 0,2 | 
    %{   
        if($_.Context.PostContext -Like "*sip*")
        {
            # This outputs: edit <id> \n (\r) sip
            $FindID = $_.Context.PostContext
            # Converting the plain text id (string/system object) to an int
            $FindID = $FindID -replace "[^0-9]"
            $FindID = [string]$FindID
            $FindID = [int]$FindID
            $SSH1.WriteLine("delete $FindID")
            Start-Sleep -Milliseconds 100
        }
    }

    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config system settings")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set sip-expectation disable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set sip-nat-trace disable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set sip-helper disable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set default-voip-alg-mode kernel-helper-based")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config voip profile")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit default")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config sip")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set rtp disable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set status disable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    
    Write-Host "All Done, ALG is now disabled on your firewall. Reboot needed."
    Start-Sleep -Seconds 3
}
#endregion
