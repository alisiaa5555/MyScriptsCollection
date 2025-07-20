<#
I pulled out the last created checkpoint (variable $lastChkptime) in order to compare in if 24 hours (1440 minutes) passed since last checkpoint was created since using the script it's not possible to create more than 1 within 24 hours (this option is available when creating restore points in GUI).  If 24 hours passed or the variable $lastChkptime is null the function CreateMyRestorePoint is called. A new checkpoint gets created and then the script checks if there are 2 or more existing checkpoints (for example created manually or by the system like Windows updates etc.) and if yes, then the oldest checkpoint is deleted.
In $lastChkptime, I had to select only last checkpoint time since if the result was 2 or more checkpoints, $lastChkptime variable would be an array and then conversion '($lastChkptime.Date).ToString("yyyy/MM/dd HH:mm:ss")' would fail.
Creation time is returned as string in format yyyymmddHHMMSS.mmmmmmsUUU in Get-ComputerRestorePoint hence it had to be converted using [System.Management.ManagementDateTimeConverter]::ToDateTime.
I used a TimeSpan object to subtract time: $ConvertedTime - $actualTime.

In regards to deleting the oldest restore points there seems to be no command for it in PowerShell. Instead I googled and found out a cmd command 
vssadmin can be used.
In my case I used vssadmin Delete Shadows /For=C: /Oldest /Quiet to delete the oldest restore point without having to confirm the action.
#>

$CurrentTime=(Get-Date).ToString("yyyy/MM/dd hh/mm")
$ChcpntName="My Restore Point $CurrentTime"
$Logs = "C:\Users\...\CheckPoint\CheckpointLogs.txt" 

function CreateMyRestorePoint {
<#
.DESCRIPTION
   A Function that creates restore point and delete the oldest one if there are 2 or more exisiting checkpoints.

.EXAMPLE
    CreateMyRestorePoint
#> 

    Write-Host "Trying to create a checkpoint..."
    Checkpoint-Computer -Description "$ChcpntName" -RestorePointType MODIFY_SETTINGS
    Write-Host "Checkpoint created successfully."
    $createdRP =  Get-ComputerRestorePoint
    Write-Host "Created '$($createdRP.description)' checkpoint."
     $getCreatedRS = @()
        $getCreatedRS = Get-ComputerRestorePoint
            if ($getCreatedRS.Count -ge 2){
                vssadmin Delete Shadows /For=C: /Oldest /Quiet  
                Write-Host "The oldest checkpoint was deleted."
            }
}

Start-Transcript -Path $Logs 

$lastChkptime = Get-ComputerRestorePoint | Select-Object -Last 1 @{Name='Date';Expression={[System.Management.ManagementDateTimeConverter]::ToDateTime($_.CreationTime)}}

if ($lastChkptime -eq $null){
    CreateMyRestorePoint
}elseif ($lastChkptime -ne $null) {
    Write-Host "Checking how many minutes passed since last checkpoint was created..."
    $ConvertedTime = ($lastChkptime.Date).ToString("yyyy/MM/dd HH:mm:ss") 
    $actualTime = (get-date).ToString("yyyy/MM/dd HH:mm:ss")
    
    $timeDiff = NEW-TIMESPAN -Start $ConvertedTime –End $actualTime 
    Write-Host "Time difference is $timeDiff. "
    if ($timeDiff.Minutes -gt 1440){
        CreateMyRestorePoint
    }else {
            Write-Host "The last checkpoint was created less than 24 hours ago. Script ended."
    }
}
  
Stop-Transcript
