#region Firewall Off
 
function Set-FGTOff
{
    param(
    [parameter(Mandatory=$true)]
    $Session
    )
    
    Clear-Host
    Write-Host ""
    Write-Host "`n*** Power - Fortigate Unit ***`n" -ForegroundColor Green

    Write-Host "`n*** Menu ***`n" -ForegroundColor Green
    Write-Host "1) Reboot"
    Write-Host "2) Power off"
    Write-Host "3) Go back"
    Write-Host "`n************" -ForegroundColor Green
    
    $ChsAction = Read-Host -Prompt "`nChoose an option"

    switch($ChsAction)
    {
        default
        {
            return
        }
        1
        {
            $SSH1 = New-SSHShellStream -Index $Session.SessionId
            $SSH1.WriteLine("exec reboot")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("y")
            Start-Sleep -Milliseconds 70
    
            Remove-Module FGT_* -ErrorAction SilentlyContinue
            Write-Warning "Fortigate is rebooting"
            Write-Host "`n`nWait about 3-5 minutes before trying to reconnect.`n"
            Write-Host "... exiting now ...`n" -ForegroundColor Red
            exit 0
        }
        2
        {
            $SSH1 = New-SSHShellStream -Index $Session.SessionId
            $SSH1.WriteLine("exec shutdown")
            Start-Sleep -Milliseconds 70
            $SSH1.WriteLine("y")
            Start-Sleep -Milliseconds 70
    
            Remove-Module FGT_* -ErrorAction SilentlyContinue
            Write-Warning "Fortigate is shutting down`n"
            Write-Host "... exiting now ...`n" -ForegroundColor Red
            exit 0
        }

    }
}
#endregion
