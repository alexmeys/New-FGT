#region Data for WAN 
function Set-FGTWan
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
     
    # Getting data for WAN configuration
    Clear-Host
    Write-Host ""
    Write-Host "*** Get data for WAN ***`n" -ForegroundColor Green

    $whatwan = Read-Host -Prompt "What interface is your WAN interface (Default WAN1; possible WAN2, DMZ)"
    

    if([string]::IsNullOrEmpty($whatwan))
    {
        $whatwan = "WAN1"
    }

    $whatwan = $whatwan.ToLower()

    switch ($whatwan)
    {
        wan1
        {
            $WanInt1 = Read-Host -prompt "Do you want DHCP on WAN1 (y/n)"

            if (($WanInt1 -eq "y") -or ($WanInt1 -eq "yes"))
            {
                Write-Host "We will configure DHCP on the WAN1 interface"
            }
            else
            {
                Write-Host "You want a static address, let met get some more information."
                Write-Host "`nKeep in mind to choose a different subnet compared to your Lan!"
                $WanInt1IP = Read-Host -Prompt "Enter WAN1 IP address (a.b.c.d)"
                $WanInt1Sub = Read-Host -Prompt "Subnet of the WAN1"
                $WanInt1GW = Read-Host -Prompt "Default Gateway for Wan1"
            }
        }
        wan2
        {
            $WanInt2 = Read-Host -prompt "Do you want DHCP on WAN2 (y/n)"

            if (($WanInt2 -eq "y") -or ($WanInt2 -eq "yes"))
            {
                Write-Host "We will configure DHCP on the WAN2 interface"
            }
            else
            {
                Write-Host "You want a static address, let met get some more information."
                Write-Host "`nKeep in mind to choose a different subnet compared to your Lan!"
                $WanInt2IP = Read-Host -Prompt "Enter WAN2 IP address (a.b.c.d)"
                $WanInt2Sub = Read-Host -Prompt "Subnet of the WAN2"
                $WanInt2GW = Read-Host -Prompt "Default Gateway for Wan2"
            }        
        }
        dmz
        {
            $WanIntDMZ = Read-Host -prompt "Do you want DHCP on DMZ (y/n)"

            if (($WanIntDMZ -eq "y") -or ($WanIntDMZ -eq "yes"))
            {
                Write-Host "We will configure DHCP on the DMZ interface"
            }
            else
            {
                Write-Host "You want a static address, let met get some more information."
                Write-Host "`nKeep in mind to choose a different subnet compared to your Lan!"
                $WanIntDMZIP = Read-Host -Prompt "Enter DMZ IP address (a.b.c.d)"
                $WanIntDMZSub = Read-Host -Prompt "Subnet of the DMZ"
                $WanIntDMZGW = Read-Host -Prompt "Default Gateway for DMZ"
            }        
        }
        default
        {
            Write-Host "`nYou have chosen an incorrect option, so I'm defaulting to WAN1." -ForegroundColor Red
            $whatwan = 'WAN1'
            $WanInt1 = Read-Host -prompt "Do you want DHCP on WAN1 (y/n/exit)"

            if ($WanInt1 -eq "exit")
            {
                Write-Host "`nOk, We stop the execution of the wan configuration`n" -ForegroundColor Red
                Start-Sleep -Seconds 1
                return
            }
            elseif (($WanInt1 -eq "y") -and ($WanInt1 -eq "yes"))
            {
                Write-Host "We will configure DHCP on the WAN1 interface"
            }
            else
            {
                Write-Host "You want a static address, let met get some more information."
                Write-Host "`nKeep in mind to choose a different subnet compared to your Lan!"
                $WanInt1IP = Read-Host -Prompt "Complete WAN1 IP address (a.b.c.d)"
                $WanInt1Sub = Read-Host -Prompt "Subnet of the WAN1"
                $WanInt1GW = Read-Host -Prompt "Default Gateway for Wan1"
            }  
        }

    }

    $Global:WanInt = $whatwan

    # Start SSH Straeming session 
    $SSH1 = New-SSHShellStream -Index $Session.SessionId

    #Set WAN1 interface device configuration
    Write-Host "*** Set data for WAN ***`n" -ForegroundColor Green
    
    switch($whatwan)
    {
        WAN1
        {
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("get hardware nic wan1")
            Start-Sleep -Milliseconds 250
            $wanMacOut = $SSH1.Read()
            Start-Sleep -Milliseconds 70
            Write-Warning "Your MAC address information, in case you need it:`n"
            Write-Host $wanMacOut

            if([string]::IsNullOrEmpty($WanInt1IP))
            {
                #They opted for DHCP on WAN1 interface
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit wan1")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode dhcp")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 70
            }
            else
            {
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit wan1")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set ip $WanInt1IP $WanInt1Sub")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set allowaccess ping https http fgfm auto-ipsec")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set alias 'Internet'")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 70
                
                #Wan set, routing to the outside needed
                $SSH1.WriteLine("config router static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit 1")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("set gateway $WanInt1GW")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set device 'wan1'")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60

            }
            Write-Host "`nAll done configuring your interface`n"
            pause 
        }
        WAN2
        {
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("get hardware nic wan2")
            Start-Sleep -Milliseconds 250
            $wanMacOut = $SSH1.Read()
            Start-Sleep -Milliseconds 70
            Write-Warning "Your MAC address information, in case you need it:`n"
            Write-Host $wanMacOut

            if([string]::IsNullOrEmpty($WanInt2IP))
            {
                #They opted for DHCP on DMZ interface
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit wan2")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode dhcp")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60

            }
            else
            {
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit wan2")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set ip $WanInt2IP $WanInt2Sub")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set allowaccess ping https http fgfm auto-ipsec")
                Start-Sleep -Milliseconds 70
                $SSH1.WritreLine("set alias 'Internet'")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60

                #Wan set, routing to the outside needed
                $SSH1.WriteLine("config router static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit 1")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("set gateway $WanInt2GW")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set device 'wan2'")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60
            }
            Write-Host "`nAll done configuring your interface`n"
            pause 
        }
        DMZ
        {
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("get hardware nic dmz")
            Start-Sleep -Milliseconds 250
            $wanMacOut = $SSH1.Read()
            Start-Sleep -Milliseconds 70
            Write-Warning "Your MAC address information, in case you need it:`n"
            Write-Host $wanMacOut
            
            if([string]::IsNullOrEmpty($WanIntDMZIP))
            {
                #They opted for DHCP on DMZ interface
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit dmz")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode dhcp")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60
            }
            else
            {
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit dmz")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set ip $WanIntDMZIP $WanIntDMZSub")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set allowaccess ping https http fgfm auto-ipsec")
                Start-Sleep -Milliseconds 70
                $SSH1.WritreLine("set alias 'Internet'")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60

                #Wan set, routing to the outside needed
                $SSH1.WriteLine("config router static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit 1")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("set gateway $WanIntDMZGW")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set device 'dmz'")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60
            }
            Write-Host "`nAll done configuring your interface`n"
            pause 
        }
        default
        {
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("get hardware nic wan1")
            Start-Sleep -Milliseconds 250
            $wanMacOut = $SSH1.Read()
            Start-Sleep -Milliseconds 70
            Write-Warning "Your MAC address information, in case you need it:`n"
            Write-Host $wanMacOut
            
            if([string]::IsNullOrEmpty($WanInt1IP))
            {
                break
            }
            else
            {
                $SSH1.WriteLine("config system interface")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit wan1")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set mode static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set ip $WanInt1IP $WanInt1Sub")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set allowaccess ping https http fgfm auto-ipsec")
                Start-Sleep -Milliseconds 70
                $SSH1.WritreLine("set alias 'Internet'")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60

                #Wan set, routing to the outside needed
                $SSH1.WriteLine("config router static")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("edit 1")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("set gateway $WanInt1GW")
                Start-Sleep -Milliseconds 70
                $SSH1.WriteLine("set device 'wan1'")
                Start-Sleep -Milliseconds 60
                $SSH1.WriteLine("end")
                Start-Sleep -Milliseconds 60
            }
            Write-Host "`nAll done configuring your interface`n"
            pause 
        }
    }

}
#endregion