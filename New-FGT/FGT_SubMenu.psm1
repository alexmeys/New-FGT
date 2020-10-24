#region Submenu
 
#basically a repeating for every submenu, menu.
function Read-Submenu {
    param(
    [parameter(Mandatory=$true)]
    $SbName
    )

    Clear-Host
    Write-Host""

    Write-Host "`n*** Menu $SbName ***`n" -ForegroundColor Green
    Write-Host "1) Configure $SbName"
    Write-Host "2) Return to main menu"
    Write-Host "`n****************" -ForegroundColor Green

    $OptChs = Read-Host -Prompt "`nChoose an option (exit to leave)"

    switch($OptChs)
    {
        default
        {
            # Bit off an overkill but clean all modules and leave
            Remove-FGTSsh
            Remove-Module FGT_Ssh -ErrorAction SilentlyContinue
            Remove-Module FGT_Dns -ErrorAction SilentlyContinue
            Remove-Module FGT_Bup -ErrorAction SilentlyContinue
            Remove-Module FGT_Info -ErrorAction SilentlyContinue
            Remove-Module FGT_Policy -ErrorAction SilentlyContinue
            Remove-Module FGT_Lan -ErrorAction SilentlyContinue
            Remove-Module FGT_Wan -ErrorAction SilentlyContinue
            Remove-Module FGT_* -ErrorAction SilentlyContinue
            Write-Host "... exiting now ..." -ForegroundColor Red
            exit 0
        }
        1
        {
            $global:answSub=1 
            break
        }
        2
        {
            $global:answSub=2 
            break
        }

    }

}
#endregion
