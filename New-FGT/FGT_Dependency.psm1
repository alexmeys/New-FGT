#region Dependency check
#Check if Posh-SSH is installed if not this will install it
#Gives the user 15 seconds to read the messages before clearing the screen.
#In case of error script will exit with an error 1.
function Test-Dependency
{
    Write-Host "`n*** Dependency Checks ***`n" -ForegroundColor Green

    Write-Host "First things first."
    Write-Host "A dependency 'Posh-SSH' is not installed, let me help you get that."
    Write-Host "The module will be installed for this user only `nand stored in $home\Documents\PowerShell\Modules"
    Write-Host "This is so that we do not get UAC prompts and annoying login information"
    Write-Host "You can always remove the Module manually with 'Uninstall-Module Posh-SSH' afterwards."
    Write-Host "`n*************************`n`n" -ForegroundColor Green
    Start-Sleep -Seconds 12

    if ((Install-Module -Scope CurrentUser -Name "Posh-SSH") -eq $null)
    {
        Write-Host "`n`nSuccessful installation`n" -ForegroundColor Green
        Start-Sleep -Seconds 3
        Clear-Host
        Write-Host "`n`n*** Connecting to a FGT Unit ***`n`n" -ForegroundColor Green
    }
    else
    {
        Write-Host "Something went wrong, please try to install Posh-SSH manually first, before running the script`n" -ForegroundColor Red
        Write-Host "You can do this in Powershell with Module-Install Posh-SSH or manually downloading the file from PS Gallery" -ForegroundColor Red
        Remove-Module FGT_* -ErrorAction SilentlyContinue
        Write-Host "`n... exiting now ...`n" -ForegroundColor Red
        exit 1
    } 
}
#endregion