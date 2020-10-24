#region Lets get started
 
function New-FGTInit
{
    Clear-Host
    Start-Sleep -Milliseconds 20
    Write-Host "`n`n*** Connecting to a FGT Unit ***`n`n" -ForegroundColor Green

    #Display Welcome message while checking if the dependency Posh-SSH is installed.
    write-host "Hi, Welcome. This script will configure your Fortigate Unit."
    Write-Host "Hope you like it and find it useful, good luck!`n"

    Write-Host "Ok Great, lets get started with the connection to your"
    Write-Host "Fortigate Unit. Please connect your Fortigate Unit to your computer `nwith the LAN cable."
    if ((Get-InstalledModule -Name "Posh-SSH" -ErrorAction SilentlyContinue) -eq $null)
    {
        Import-Module $PSScriptRoot\FGT_Dependency.psm1
        Test-Dependency
    }
    Write-Host "`nOn your computer, set a static, subnet and gateway address."
    Write-Host "`nFor example for a new device:" -ForegroundColor Cyan
    Write-Host "IP: 192.168.1.188" -ForegroundColor Cyan
    Write-Host "Subnet: 255.255.255.0" -ForegroundColor Cyan
    Write-Host "Gateway: 192.168.1.99 ( Current Fortigate Unit IP )" -ForegroundColor Cyan
    Write-Host "`nSome Unit's will do this for you if DHCP is configured out of the box. `nMost won't, so you will have to add a static ip like this."
    Write-Host "Once this is done, we can continue`n"

    # Start input gathering and evaluating

    $Global:HostName = Read-Host -Prompt "What is your current Fortigate unit ip address (Default: 192.168.1.99)"

    if([string]::IsNullOrEmpty($Global:HostName))
    {
        $Global:HostName = "192.168.1.99"
    }
    else 
    {
        $Global:HostName = $Global:HostName
    }
    
    Clear-Host
    Write-Host "`n`n*** Starting SSH Session to: $Global:HostName ***`n`n" -ForegroundColor Green

    for($i=1;$i -le 3; $i++)
    {
        
        Write-Host "Enter username and password in the popup window."
        Write-Host "Default User is admin and no password needed.`n"

        $credz = $host.ui.PromptForCredential("Enter FGT Credentials", "Please input your Fortigate Unit credentials.","admin","")
        try
        {
            Write-Host "`nOne moment trying to setup new connection with the supplied information..."
            Write-Host "Attempt $i/3`n`n"
            $start = New-SSHSession -ComputerName $Global:HostName -Credential $credz -ErrorAction SilentlyContinue -AcceptKey
        }
        catch
        {
            Write-Host ""
        }
        if(-not($start))
        {
            Write-Host "Something went wrong with setting up the connection. Let me see if I can figure out what is it most likely the case.`n"
            $Response = Test-Connection -ComputerName $Global:HostName -Count 1 -Quiet
            if($Response -eq $false)
            {
                Write-Warning "`nI'm not able to reach or connect to your Fortigate Unit over the network.`n"

                Write-Host "`n1) Check your network cable, going from LAN port X to your computer network port."            
                Write-Host "2) Check that you have a static IP configured in the correct range and the gateway is your Fortigate unit."
                Write-Host "3) Try to ping your gateway, or maybe connect with a console cable to check, maybe it is stuck at boot..."   
                Write-Host "4) Are you sure that your Fortigate Unit IP is: $Global:HostName ? You can change it on the next screen."
                Write-Host "5) Sometimes SSH is not enabled on your FGT Interface and ping is disabled, you can adjust that from HTTPS or Console.`n"
                Write-Host "I will pause here, so you have to time to check or connect your device."
            }
            else
            {
                Write-Warning "`nMost probably the supplied password is wrong." 
                Write-Host "`nI can reach your device, but cannot connect to it."
                Write-Host "`n1) Check that the password is correct."
                Write-Host "2) Double check for Azerty/Qwerty keyboard issues"
                Write-Host "3) After 3 wrong password attempts there is lockout for a minute, try again later."
                Write-Host "4) Sometimes on your FGT Interface SSH is not enabled.`n"
                Write-Host "I will pause here, so you have to time to check."

            }
            if ($i -eq 3)
            {
                Write-Host "`nI'm sorry, you tried 3 times. You are now probably locked out, try again in 1 minute.`n" -ForegroundColor Red
                Remove-Module FGT_* -ErrorAction SilentlyContinue
                Write-Host "... exiting now ...`n" -ForegroundColor Red
                exit 1
            }
            Write-Host "`n"
            pause
            
            Write-Host "`n`nRe-Enter your Fortigate Unit-IP, you can leave it empty if it's the correct IP."
            $HostAgain = Read-Host -Prompt "Enter IP (or type exit to leave)"

            if([string]::IsNullOrEmpty($HostAgain))
            {
                $Global:HostName = $Global:HostName
            }
            elseif ($HostAgain -eq 'exit')
            {
                Remove-Module FGT_* -ErrorAction SilentlyContinue
                Write-Host "... exiting now ...`n" -ForegroundColor Red
                exit 0    
            }
            else
            {
                $Global:HostName = $HostAgain
            }

            Clear-Host
            Write-Host "`n`n*** Starting SSH Session to: $Global:HostName ***`n`n" -ForegroundColor Green
        }
        else 
        {
            return $start
        }
    }



} 
#endregion

#region End SSH Session
# Stop & remove SSH session
function Remove-FGTSsh
{
    foreach ($item in Get-SSHSession)
    {
        Remove-SSHSession $item > $null 2>&1
    }

    
}
#endregion
