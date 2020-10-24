#region Get basic information
function Set-FGTInfo
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
     
    Clear-Host
    Write-Host ""
    Write-Host "`n*** Set general info ***`n" -ForegroundColor Green

    # Start gathering information about changes the user wants
    $DevName = Read-Host -Prompt "What will the device name be (0-9,a-Z)"
    $ChgPw = Read-Host -Prompt "Do you want to change the password (y/n)"
    if($ChgPw -eq 'y')
    {
        $NewPw = Read-Host -Prompt "Enter your desired password"
    }

    $ChgMgmtPort = Read-Host -Prompt "Do you want to change the https management port (y/n)"
    if($ChgMgmtPort -eq 'y')
    {
        $NewMgmtPort = Read-Host -Prompt "Enter your desired port number"
    }


    Write-Host "`nA long list of countries is coming, please pick your correct timezone `nand type the number below the list.`n"
    pause

    $LSCountry = "
    01    (GMT-11:00) Midway Island, Samoa
    02    (GMT-10:00) Hawaii
    03    (GMT-9:00) Alaska
    04    (GMT-8:00) Pacific Time (US & Canada)
    05    (GMT-7:00) Arizona
    81    (GMT-7:00) Baja California Sur, Chihuahua
    06    (GMT-7:00) Mountain Time (US & Canada)
    07    (GMT-6:00) Central America
    08    (GMT-6:00) Central Time (US & Canada)
    09    (GMT-6:00) Mexico City
    10    (GMT-6:00) Saskatchewan
    11    (GMT-5:00) Bogota, Lima,Quito
    12    (GMT-5:00) Eastern Time (US & Canada)
    13    (GMT-5:00) Indiana (East)
    74    (GMT-4:00) Caracas
    14    (GMT-4:00) Atlantic Time (Canada)
    77    (GMT-4:00) Georgetown
    15    (GMT-4:00) La Paz
    87    (GMT-4:00) Paraguay
    16    (GMT-3:00) Santiago
    17    (GMT-3:30) Newfoundland
    18    (GMT-3:00) Brasilia
    19    (GMT-3:00) Buenos Aires
    20    (GMT-3:00) Nuuk (Greenland)
    75    (GMT-3:00) Uruguay
    21    (GMT-2:00) Mid-Atlantic
    22    (GMT-1:00) Azores
    23    (GMT-1:00) Cape Verde Is.
    24    (GMT) Monrovia
    80    (GMT) Greenwich Mean Time
    79    (GMT) Casablanca
    25    (GMT) Dublin, Edinburgh, Lisbon, London, Canary Is.
    26    (GMT+1:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
    27    (GMT+1:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
    28    (GMT+1:00) Brussels, Copenhagen, Madrid, Paris
    78    (GMT+1:00) Namibia
    29    (GMT+1:00) Sarajevo, Skopje, Warsaw, Zagreb
    30    (GMT+1:00) West Central Africa
    31    (GMT+2:00) Athens, Sofia, Vilnius
    32    (GMT+2:00) Bucharest
    33    (GMT+2:00) Cairo
    34    (GMT+2:00) Harare, Pretoria
    35    (GMT+2:00) Helsinki, Riga, Tallinn
    36    (GMT+2:00) Jerusalem
    37    (GMT+3:00) Baghdad
    38    (GMT+3:00) Kuwait, Riyadh
    83    (GMT+3:00) Moscow
    84    (GMT+3:00) Minsk
    40    (GMT+3:00) Nairobi
    85    (GMT+3:00) Istanbul
    41    (GMT+3:30) Tehran
    42    (GMT+4:00) Abu Dhabi, Muscat
    43    (GMT+4:00) Baku
    39    (GMT+3:00) St. Petersburg, Volgograd
    44    (GMT+4:30) Kabul
    46    (GMT+5:00) Islamabad, Karachi, Tashkent
    47    (GMT+5:30) Kolkata, Chennai, Mumbai, New Delhi
    51    (GMT+5:30) Sri Jayawardenepara
    48    (GMT+5:45) Kathmandu
    45    (GMT+5:00) Ekaterinburg
    49    (GMT+6:00) Almaty, Novosibirsk
    50    (GMT+6:00) Astana, Dhaka
    52    (GMT+6:30) Rangoon
    53    (GMT+7:00) Bangkok, Hanoi, Jakarta
    54    (GMT+7:00) Krasnoyarsk
    55    (GMT+8:00) Beijing, ChongQing, HongKong, Urumgi, Irkutsk
    56    (GMT+8:00) Ulaan Bataar
    57    (GMT+8:00) Kuala Lumpur, Singapore
    58    (GMT+8:00) Perth
    59    (GMT+8:00) Taipei
    60    (GMT+9:00) Osaka, Sapporo, Tokyo, Seoul
    62    (GMT+9:30) Adelaide
    63    (GMT+9:30) Darwin
    61    (GMT+9:00) Yakutsk
    64    (GMT+10:00) Brisbane
    65    (GMT+10:00) Canberra, Melbourne, Sydney
    66    (GMT+10:00) Guam, Port Moresby
    67    (GMT+10:00) Hobart
    68    (GMT+10:00) Vladivostok
    69    (GMT+10:00) Magadan
    70    (GMT+11:00) Solomon Is., New Caledonia
    71    (GMT+12:00) Auckland, Wellington
    72    (GMT+12:00) Fiji, Kamchatka, Marshall Is.
    00    (GMT+12:00) Eniwetok, Kwajalein
    82    (GMT+12:45) Chatham Islands
    73    (GMT+13:00) Nuku'alofa
    86    (GMT+13:00) Samoa
    76    (GMT+14:00) Kiritimati
"
    $LSCountry | Format-List | Out-String | Write-Host

    $TimeZn = Read-Host -Prompt "What is your timezone, choose a number"
    
    #Start a SSH Streaming session
    $SSH1 = New-SSHShellStream -Index $Session.SessionId
    Start-Sleep -Milliseconds 20

    Write-Host "`n*** Set general data ***`n" -ForegroundColor Green

    Write-Host "`nOne moment setting configuration"
    
    ##Set Hostname & Timezone & some basic stuff
    $SSH1.WriteLine("config system global")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set hostname $DevName")
    Start-Sleep -Milliseconds 80
    $SSH1.WriteLine("set timezone $TimeZn")
    Start-Sleep -Milliseconds 80
    $SSH1.WriteLine("set fds-statistics enable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set admin-scp enable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config ips global")
    Start-Sleep -Milliseconds 100
    $SSH1.WriteLine("set database extended")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 60
    $SSH1.WriteLine("config system session-ttl")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set default 28800")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config system autoupdate push-update")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set status enable")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("config system console")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("set output standard")
    Start-Sleep -Milliseconds 70
    $SSH1.WriteLine("end")
    Start-Sleep -Milliseconds 60

    # In case a different web mgmt port is wanted...
    if($NewMgmtPort)
    {
        $SSH1.WriteLine("config system global")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set admin-sport $NewMgmtPort")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set password $NewPw")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("end")
    }

    # In case a password change is wanted...
    if($NewPw)
    {
        $SSH1.WriteLine("config system admin")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("edit admin")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("set password $NewPw")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("next")
        Start-Sleep -Milliseconds 70
        $SSH1.WriteLine("end")

        Write-Host "You changed the password! The script will now close. Login again with with this script and your new credentials."
        Write-Host "This will make a new secure connection to your FGT Unit and you can continue configuring your device!"

        Remove-Module FGT_* -ErrorAction SilentlyContinue
        Write-Host "... exiting now ...`n" -ForegroundColor Red
        exit 0
    }

    Write-Host "`nAll Done!`n"
    Start-Sleep -Seconds 2
}
#endregion