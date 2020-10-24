#region Data for DNS
function Set-FGTDns
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

    #Gather DNS required data
    Write-Host "`n*** Get data for DNS ***`n" -ForegroundColor Green

    $whatdns = Read-Host -Prompt "Do you like to set your own DNS (y/n)"

    if(($whatdns -eq 'y') -or ($whatdns -eq 'yes'))
    {
        $dns1 = Read-Host -Prompt "Enter your first DNS server"
        $dns2 = Read-Host -Prompt "Enter your second DNS server (otherwise leave empty)"
        $dom1 = Read-Host -Prompt "Enter your local domain (otherwise leave empty)" 
    }
    else
    {
        Write-Host "`nYou will be using Fortiguard servers from now on." -ForegroundColor Yellow
        $dns1 = '208.91.112.53'
        $dns2 = '208.91.112.52'
        Start-Sleep -Seconds 3
    }

    
    Write-Host "`n*** Setting data for DNS ***`n" -ForegroundColor Green
    Start-Sleep -Seconds 1
    
    #Setting a DNS so we can browse the web
    if([string]::IsNullOrEmpty($dns1))
    {
        Write-Host "You do not need DNS to be configured.`nIf you do, please add atleast one DNS server."
        return
    }
    else
    {
        #Start SSH Streaming session
        $SSH1 = New-SSHShellStream -Index $Session.SessionId

        Write-Host "`n*** Set data for DNS ***`n" -ForegroundColor Green
        

        $SSH1.WriteLine("config system dns")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set primary $dns1")
        Start-Sleep -Milliseconds 70

        if([string]::IsNullOrEmpty($dns2))
        {
            $SSH1.WriteLine("set secondary 0.0.0.0")
            Start-Sleep -Milliseconds 70
        }
        else
        {
            $SSH1.WriteLine("set secondary $dns2")
            Start-Sleep -Milliseconds 70
        }
        if([string]::IsNullOrEmpty($dom1))
        {
            $SSH1.WriteLine("end")
            Start-Sleep -Milliseconds 60
        }
        else
        {
            $SSH1.WriteLine("set domain $dom1")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("end")
            Start-Sleep -Milliseconds 60
        }
    }
}
#endregion