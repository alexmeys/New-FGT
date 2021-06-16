#region Set Policy
 
function Set-FGTPolicy
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

    # Getting data for Policy configuration
    Clear-Host
    Start-Sleep -Milliseconds 20
    Write-Host "*** Get data for Policy's ***`n" -ForegroundColor Green

    do{
        Write-Output "To set policy's we first must know a couple of things`n"

        Write-Host "Is there an UTM bundle on your device  (separate license; AV/Web/IPS...)"
        $UtmOrNot = Read-Host -Prompt "If you have no clue, just press enter (y/n)"
        if([string]::IsNullOrEmpty($UtmOrNot)){$UtmOrNot = "No"}
        elseif($UtmOrNot -eq 'n'){$UtmOrNot = "No"}
        else{$UtmOrNot = "y"}

        $MailSrvY = Read-Host -Prompt "`nDo you have a Mailserver (y/n)"
        if($MailSrvY -eq 'y')
        {
            $MailSrv = Read-Host -Prompt "Enter the IP address of your mailserver"
        }
        
        if([string]::IsNullOrEmpty($Global:HostName))
        {
            Write-host "`nIt seems I cannot determine the internal IP of your Fortigate Unit."
            Write-Host "We need some additional details.`n"
            
            $Internal = Read-Host -Prompt "Specify your internal network (e.g.: 192.168.100.0)"
            

            $Subnet = Read-Host -Prompt "Specify your subnet (Default: 255.255.255.0)"
            if([string]::IsNullOrEmpty($Subnet)){$Subnet = '255.255.255.0'}
            else{$Subnet = $Subnet}
        }
        else
        {
            Write-Host "`nDue too the program closing after the lan settings and not keeping data persistent,"
            $Subnet = Read-host -Prompt "could you enter your internal subnet mask again? (255.255.255.0)"
            if([string]::IsNullOrEmpty($Subnet)){$Subnet = '255.255.255.0'}
            else{$Subnet = $Subnet}

            if($Subnet -eq '255.255.255.0')
            {
                $range = ($Global:HostName).split(".")
                $Internal = ("{0}.{1}.{2}.0" -f $range[0], $range[1], $range[2])
            }
            elseif($Subnet -eq '255.255.0.0')
            {
                $range = ($Global:HostName).split(".")
                $Internal = ("{0}.{1}.0.0" -f $range[0], $range[1])
            }
            elseif($Subnet -eq '255.0.0.0')
            {
                $range = ($Global:HostName).split(".")
                $Internal = ("{0}.0.0.0" -f $range[0])
            }
            else
            {
                Write-Host "`nIt looks like you don't run a default A/B/C-Style network for your lan."
                Write-Host "This is what we have so far:"
                Write-Host "IP GW: $Global:HostName" -ForegroundColor Yellow
                Write-Host "Subnet: $Subnet" -ForegroundColor Yellow
                $Internal = Read-Host -Prompt "Enter your starting network range (e.g. 192.168.100.0)"
            }
        }
        
        Write-Host "`nWill use this network range: $Internal - $Subnet"

        if([string]::IsNullOrEmpty($Global:WanInt))
        {
            do
            {
                $Uplink = Read-Host -Prompt "`nWhat is your outbound interface for network $Internal (wan,wan1,wan2 or dmz)"
            } while(($uplink -ne 'WAN1') -and ($uplink -ne 'WAN2') -and ($uplink -ne 'DMZ') -and ($uplink -ne 'WAN'))
               
            $uplink = $uplink.ToLower()
        }
        else
        {
            $uplink = $Global:wanInt
        }

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
        if($readinterfaces -like "*internal*")
        {
            $srcintf = "internal"
            $SSH1.WriteLine("end")
        }
        elseif($readinterfaces -like "*lan*")
        {
            $srcintf = "lan"
            $SSH1.WriteLine("end")
        }
        else
        {
            write-Warning "I could not find the internal interface!"
            $SSH1.WriteLine("end")
            return
        }

        Write-Host "`n`nThese are the settings we have for configuring the policy's:`n"

        Write-Host "Internal: $Internal" -ForegroundColor Yellow
        Write-Host "Subnet: $Subnet" -ForegroundColor Yellow
        Write-Host "UTM: $UtmOrNot" -ForegroundColor Yellow
        Write-Host "SrcInt: $srcintf" -ForegroundColor Yellow
        Write-Host "DstInt: $uplink" -ForegroundColor Yellow
        if($MailSrv){Write-Host "Mailsrv: $MailSrv" -ForegroundColor Yellow}

        $correct = Read-Host -Prompt "`nAre those settings looking good for you (y/n)?"
        $N32 = "255.255.255.255"

        Clear-Host
        Write-Host "*** Get data for Policy's ***`n" -ForegroundColor Green

    }while($correct -ne 'y')

    Clear-Host

    Write-Host ""
    Write-Host "`n*** Set policy data for LAN network ***`n" -ForegroundColor Green
    Write-Host "`nOne Moment creating and applying objects and policy's"

    # Set Service Objects
    $SSH1.WriteLine("config firewall service custom")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit SSL_UDP")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set udp-portrange 443")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit GFI")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set tcp-portrange 3377")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set udp-portrange 1234-1235 3337")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit TV")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set tcp-portrange 5938")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set udp-portrange 5938-5939")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit ADESK")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set tcp-portrange 7070")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit Whatsapp")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set tcp-portrange 4244 5222-5223 5228 5242 59234 50318")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set udp-portrange 59234 50318 45395 3478")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit Facetime")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set tcp-portrange 5223-5224")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set udp-portrange 16384-16387 16393-16402 3478-3479")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 60


    # Set VIP and Address Obj's
    # Adresses
    $SSH1.WriteLine("config firewall address")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("edit N_$internal")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set subnet $Internal $Subnet")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("next")
    Start-Sleep -Milliseconds 70
    if([string]::IsNullOrEmpty($MailSrv))
    {}
    else
    {
        $SSH1.WriteLine("edit H_$MailSrv")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set subnet $MailSrv $N32")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        Start-Sleep -Milliseconds 70
    }
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 60

    # VIPS
    # Still empty because inbound is specific per customer

    # Set UTM active on rules OUTbound
    if($UtmOrNot -eq "y")
    {
        $SSH1.WriteLine("config firewall policy")
        Start-Sleep -Milliseconds 70
#Policy 1 - Internet
        $SSH1.WriteLine("edit 1")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'Internet'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic utm")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'HTTP' 'HTTPS' 'DNS' 'SSL_UDP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set webfilter-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set profile-protocol-options 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 2 - System services
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 2")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'System Services'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'NTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic disable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 3 - S-T-FTP-T
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 3")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'S-T-FTP-T'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'FTP' 'FTP_GET' 'FTP_PUT' 'TFTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set profile-protocol-options 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic utm")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 4 - ICT Tools
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 4")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'ICT_Tools'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'SSH' 'TELNET' 'TRACEROUTE' 'PING'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")

        if([string]::IsNullOrEmpty($MailSrv))
#Policy 5 - Mailsrv
        {}
        else
        {

            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("edit 5")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set name 'MailSrv'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set srcintf '$srcintf'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set dstintf '$Uplink'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set srcaddr 'H_$MailSrv'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set dstaddr 'all'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set action accept")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set schedule 'always'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set service 'SMTP'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set logtraffic all")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set nat enable")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("next")
        }
#Policy 6 - Authenticated Mail
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 6")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'AuthMail'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'IMAP' 'IMAPS' 'POP3' 'POP3S' 'SMTPS'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set profile-protocol-options 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic utm")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 7 - Block Spam Mail
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 7")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'BlockSMTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action deny")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'SMTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70

        $SSH1.WriteLine("next")
#Policy 8 - Teamviewer,GFI,Anydesk,VNC,...
        $SSH1.WriteLine("edit 8")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'RemoteControl'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic disable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'TV' 'GFI' 'VNC' 'ADESK'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 9 - Socials Streaming Video
        $SSH1.WriteLine("edit 9")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'Internet'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'Whatsapp' 'Facetime'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set webfilter-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set profile-protocol-options 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 10 - Catchall
        $SSH1.WriteLine("edit 10")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'ALL_NotDefined'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'ALL'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set utm-status enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set webfilter-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set application-list 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set profile-protocol-options 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set ssl-ssh-profile 'certificate-inspection'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        $SSH1.WriteLine("end")
        Start-Sleep -Milliseconds 60
    }
    else
    {
    # No UTM Policy's, OUTbound rules

        $SSH1.WriteLine("config firewall policy")
        Start-Sleep -Milliseconds 70
#Policy 1 - Internet
        $SSH1.WriteLine("edit 1")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'Internet'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'HTTP' 'HTTPS' 'DNS' 'SSL_UDP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 2 - System services
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 2")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'System Services'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'NTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic disable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 3 - S-T-FTP-T
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 3")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'S-T-FTP-T'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'FTP' 'FTP_GET' 'FTP_PUT' 'TFTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 4 - ICT Tools
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 4")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'ICT_Tools'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'SSH' 'TELNET' 'TRACEROUTE' 'PING'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        if([string]::IsNullOrEmpty($MailSrv))
#Policy 5 - Mailsrv
        {}
        else
        {

            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("edit 5")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set name 'MailSrv'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set srcintf '$srcintf'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set dstintf '$Uplink'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set srcaddr 'H_$MailSrv'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set dstaddr 'all'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set action accept")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set schedule 'always'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set service 'SMTP'")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set logtraffic all")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("set nat enable")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("next")
        }
#Policy 6 - Authenticated Mail
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 6")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'AuthMail'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$Uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'IMAP' 'IMAPS' 'POP3' 'POP3S' 'SMTPS'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set av-profile 'default'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")

#Policy 7 - Block Spam Mail
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit 7")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'BlockSMTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf '$srcintf'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf '$uplink'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action deny")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'SMTP'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 8 - Teamviewer,GFI,Anydesk,VNC,...
        $SSH1.WriteLine("edit 8")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'RemoteControl'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic disable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'TV' 'GFI' 'VNC' 'ADESK'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 9 - Socials Streaming Video
        $SSH1.WriteLine("edit 9")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'Internet'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'N_$internal'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'Whatsapp' 'Facetime'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
#Policy 10 - Catchall
        $SSH1.WriteLine("edit 10")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set name 'ALL_NotDefined'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcintf $srcintf")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstintf $Uplink")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set srcaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set dstaddr 'all'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set action accept")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set schedule 'always'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set logtraffic all")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set service 'ALL'")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set nat enable")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        $SSH1.WriteLine("end")
        Start-Sleep -Milliseconds 60

    }

    Write-Host ""
    Write-Warning "Important Notes: `n`n"
    write-Host "1) If you have any relays in printers/scanners/camera/IOT devices, `nthey need to relay over that mailserver or use authentication.`n"
    Write-Host "2) If you have camera's or other 'not regulary used things' that I cannot define beforehand, `nthey will go over the last rule defined as '-ALL Any Accept'`n"
    Write-host "3) Policy's are made up based on what we see as regular traffic. Any rules can be added later on or changed if need be.`n"
    Start-Sleep -Seconds 15
}

#endregion
