#region Data for LAN
 
function Set-FGTLan
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
        
    # Getting data for Lan configuration

    do
    {
        write-Host ""
        Write-Host "`n*** Get data for LAN ***`n" -ForegroundColor Green
        $LanInt1gw = Read-Host -Prompt "Enter your new Fortigate ip address (gateway)"

        if([string]::IsNullOrEmpty($LanInt1gw))
        {
            Write-Host "`n"
            Write-Warning "`n`nYou did not choose a gateway! I'll pick one for you. `nYou can always change the gateway a bit further down in this wizard.`n"
            $LanInt1gw = "192.168.100.254"
        }
        else 
        {
            $LanInt1gw = $LanInt1gw
        }

        $lanInt1gw = $lanInt1gw.TrimEnd()
        $LanInt1Sub = Read-Host -Prompt "Enter the desired subnet for the Local network (Default 255.255.255.0)"
        $LanInt1Sub = $LanInt1Sub.TrimEnd()

        if([string]::IsNullOrEmpty($LanInt1Sub))
        {
            $LanInt1Sub = "255.255.255.0"
        }
        else 
        {
            $LanInt1Sub = $LanInt1Sub
        }

        $LanInt1range = $LanInt1gw.TrimEnd()
        $LanInt1split = ($LanInt1range).Split(".")
        $LanInt1rng24 = ("{0}.{1}.{2}." -f $LanInt1split[0], $LanInt1split[1], $LanInt1split[2]) 
        $LanInt1rng16 = ("{0}.{1}." -f $LanInt1split[0], $LanInt1split[1]) 
        $LanInt1rng8 = ("{0}." -f $LanInt1split[0]) 
        $LanInt1rng0 = $null

        $LanInt1Dhcp = Read-Host -Prompt "`nDo you want DHCP to be done by your Fortigate unit on LAN (y/n)?"

        if (($LanInt1Dhcp -eq 'y') -or ($LanInt1Dhcp -eq 'yes'))
        {
			if($LanInt1Sub -eq '255.255.255.0')
			{
				#Getting things ready for dhcp

				Write-Host "`n`nOk, We need some more information."
				Write-Host "Do keep in mind the subnet supplied before ($LanInt1Sub)."
				Write-Host "`nA DHCP range example could be:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng24[1] - $LanInt1rng24[253]" -ForegroundColor Cyan
				Write-Host "Fortigate unit: $LanInt1gw" -ForegroundColor Cyan
				Write-Host "`nOr leave some space for some static addresses and start your range a bit further."
				Write-Host "`nDHCP range Example 2:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng24[20] - $LanInt1rng24[253]" -ForegroundColor Cyan
				Write-Host "Fortigate Unit: $LanInt1gw`n`n" -ForegroundColor Cyan

				$siprange = Read-Host -Prompt "Supply a start digit for your range. `nJust type the starting digit, not the whole range ($LanInt1rng24[X])"
				$eiprange = Read-Host -Prompt "`nSupply an end digit for your range. `nJust type the ending digit, not the whole range ($LanInt1rng24[X])"
		
				$newsiprange = $LanInt1rng24
				$newsiprange += $siprange

				$neweiprange = $LanInt1rng24
				$neweiprange += $eiprange

			}
			elseif($LanInt1Sub -eq '255.255.0.0')
			{
				Write-Host "`n`nOk, We need some more information."
				Write-Host "Do keep in mind the subnet supplied before ($LanInt1Sub)."
				Write-Host "`nA DHCP range example could be:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng16[0].[1] - $LanInt1rng16[255].[253]" -ForegroundColor Cyan
				Write-Host "Fortigate unit: $LanInt1gw" -ForegroundColor Cyan
				Write-Host "`nOr leave some space for some static addresses and start your range a bit further."
				Write-Host "`nDHCP range Example 2:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng16[1].[1] - $LanInt1rng16[254].[253]" -ForegroundColor Cyan
				Write-Host "Fortigate Unit: $LanInt1gw`n`n" -ForegroundColor Cyan

				$siprange = Read-Host -Prompt "Supply a start digit for your range. `nJust type the starting digits, not the whole range ($LanInt1rng16[X].[X])"
				$eiprange = Read-Host -Prompt "`nSupply an end digit for your range. `nJust type the ending digits, not the whole range ($LanInt1rng16[X].[X])"
		
				$newsiprange = $LanInt1rng16
				$newsiprange += $siprange

				$neweiprange = $LanInt1rng16
				$neweiprange += $eiprange
			}
			elseif($lanInt1Sub -eq '255.0.0.0')
			{
				Write-Host "`n`nOk, We need some more information."
				Write-Host "Do keep in mind the subnet supplied before ($LanInt1Sub)."
				Write-Host "`nA DHCP range example could be:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng8[0].[0].[1] - $LanInt1rng8[255].[255].[254]" -ForegroundColor Cyan
				Write-Host "Fortigate unit: $LanInt1gw" -ForegroundColor Cyan
				Write-Host "`nOr leave some space for some static addresses and start your range a bit further."
				Write-Host "`nDHCP range Example 2:" -ForegroundColor Cyan
				Write-Host "Lan: $LanInt1rng8[1].[0].[1] - $LanInt1rng8[1].[255].[254]" -ForegroundColor Cyan
				Write-Host "Fortigate Unit: $LanInt1gw`n`n" -ForegroundColor Cyan

				$siprange = Read-Host -Prompt "Supply a start digit for your range. `nJust type the starting digits, not the whole range ($LanInt1rng8[X].[X].[X])"
				$eiprange = Read-Host -Prompt "`nSupply an end digit for your range. `nJust type the ending digits, not the whole range ($LanInt1rng8[X].[X].[X])"
		
				$newsiprange = $LanInt1rng8
				$newsiprange += $siprange

				$neweiprange = $LanInt1rng8
				$neweiprange += $eiprange
			}
			else
			{
				Write-Host "`n`nOk, We need some more information."
				Write-Host "Do keep in mind the subnet supplied before ($LanInt1Sub)."
				Write-Host "`nSince you went with a custom subnet, I figure you know what you are doing!"
				Write-Host "An example, FGT Unit 192.168.14.1, 192.168.14.2-192.168.14.14 as DHCP for a 255.255.255.240`n`n"
				Write-Host "Fortigate Unit: $LanInt1gw`n`n" -ForegroundColor Cyan

				$siprange = Read-Host -Prompt "Supply a starting range for your DHCP range.  ($LanInt1rng0[X].[X].[X].[X])"
				$eiprange = Read-Host -Prompt "`nSupply an ending range for your DHCP range. ($LanInt1rng0[X].[X].[X].[X])"
		
				$newsiprange = $LanInt1rng0
				$newsiprange += $siprange

				$neweiprange = $LanInt1rng0
				$neweiprange += $eiprange
			}

            #Just double checking and sending info to end user
            Write-Host "`nYou have chosen for:" -ForegroundColor Yellow
            Write-Host "DHCP Range: $newsiprange - $neweiprange" -ForegroundColor Yellow
            Write-Host "Subnet: $LanInt1Sub" -ForegroundColor Yellow
            Write-Host "Gateway: $LanInt1gw" -ForegroundColor Yellow
        }
        else
        {
            Write-Host "Ok, No DHCP for you. `nBe certain you have a DHCP server running. `nOr don't forget to add a static address to your computer. `nFirewall IP: ($LanInt1gw)"
        }

        $again = Read-Host -Prompt "`nAre those settings looking good for you (y/n)?"
        Clear-Host
    }while($again -ne 'y')

    $Global:LanIP = $LanInt1gw
    $Global:Subnet = $LanInt1Sub
     
    Clear-Host
    
    #Starting a SSH Streaming session.
    $SSH1 = New-SSHShellStream -Index $Session.SessionId

    #finding out what interface this FGT is using (Lan VS Internal)
    $SSH1.WriteLine("config system console")
    Start-sleep -Milliseconds 70
    $SSH1.WriteLine("set output standard")
    Start-sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-sleep -Milliseconds 70
    $SSH1.WriteLine("config system interface")
    Start-sleep -Milliseconds 70
    $SSH1.WriteLine("show")
    Start-SLeep -Milliseconds 500
    $readinterfaces = $SSH1.Read()
    if($readinterfaces -like "*Lan*")
    {
        $srcintf = "lan"
        $SSH1.WriteLine("end")
    }
    elseif($readinterfaces -like "*internal*")
    {
        $srcintf = "internal"
        $SSH1.WriteLine("end")
    }
    else
    {
        write-Warning "I could not find the internal interface!"
		$SSH1.WriteLine("end")
		Start-Sleep -Seconds 5
        return
    }

    Write-Host "`n*** Set data for $srcintf ***`n" -ForegroundColor Green

    #Set local DHCP configuration
    if(($LanInt1Dhcp -eq "N") -or ($LanInt1Dhcp -eq "n"))
    {
        Write-Host "No DHCP will be activated."
        $SSH1.WriteLine("config system dhcp server")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("delete 1")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("end")
        Start-Sleep -Milliseconds 60
    }
    else 
    {
        Write-Host "Activating DHCP on local interface"
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("config system dhcp server")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("delete 1")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 10061988")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dns-service default")
        Start-Sleep -Milliseconds 100
        $SSH1.WriteLine("set default-gateway $LanInt1gw")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set netmask $LanInt1Sub")
        Start-Sleep -Milliseconds 70
        # One week DHCP conflict timeout check
        $SSH1.WriteLine("set conflicted-ip-timeout 604800")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set interface '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("config ip-range")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 1")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set start-ip $newsiprange")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set end-ip $neweiprange")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("end")
        Start-Sleep -Milliseconds 60
        $SSH1.WriteLine("end")
        Start-Sleep -Milliseconds 60
    }

    # Disconnect happens here
    $SSH1.WriteLine("config system interface")
	Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit $srcintf")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set ip $LanInt1gw $LanInt1Sub")
    Start-Sleep -Milliseconds 100
    $SSH1.WriteLine("set device-identification enable")
    Start-Sleep -Milliseconds 100
    $SSH1.WriteLine("end")
    #manuel cleanup, so we can restart session
    remove-Module FGT_* -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Warning "`nAfter a few seconds the device will be unreachable because the address of your fortigate unit is changing!`n`n"
    Write-Warning "`nPlease update your computer network card with the new gateway and connect again from this script to `nThe new IP: $LanInt1gw`n"
    Write-Host "`nIf you enabled DHCP, just remove the static IP from your network card LAN settings`n"
    Write-Host "... exiting now ...`n" -ForegroundColor Red
    exit 0
}

#endregion
