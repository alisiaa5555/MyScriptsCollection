<#
I wrote this script in order to automate creation of my Expenses database backups.
The script contains function that creates full backup of my DB.
First, the script checks if there are any backups created. If variable $bakLastWrite is null, function Create_DB_Backup is called and new backup is created.
Else, the script calculates the time difference using NEW-TIMESPAN cmdlet and if the difference is greater than or equal to 5, function Create_DB_Backup is called and new backup is created. Else, the script ends with information that last backup was created less than 5 ago. 
The output is logged to the path.
#>
$date = (Get-Date).ToString("yyyy/MM/dd")
$path = "C:\XXXX\Backups"
$bakPath = "$path\backup-$date.bak"
$logPath = "C:\XXXX\Backup_logs\log-$date.txt"
$serverInstance = "COMPUTERNAME\SQLEXPRESS"
$database = "ExpensesDB"
$days = 5

function Create_DB_Backup {
        try {
        Backup-SqlDatabase -ServerInstance $serverInstance -Database $database -BackupFile $bakPath
        $backHistory = Get-ChildItem -Path $path
        Write-Host "Backup created: `n $backHistory"
        }catch {
        Write-Host "An error occured while creating backup."
        }
}

Start-Transcript $logPath
Write-Host "Backup_date: $date"
$getCreatedBak = Get-ChildItem -Path $path | Select-Object LastWriteTime -Last 1
$bakLastWrite = $getCreatedBak.LastWriteTime 
$actualTime = (get-date).ToString("yyyy/MM/dd")
$backHistory = Get-ChildItem -Path $path


if ($bakLastWrite -eq $null){
    Write-Host "No backups found. Trying to create a backup..."
    Create_DB_Backup
}
else {
    $timeDiff = NEW-TIMESPAN -Start $bakLastWrite –End $actualTime 
    if ($timeDiff -ge $days){
    Write-Host "Time difference is $($timeDiff.days).Trying to backup the expenses database..." 
    Create_DB_Backup 
    }
    else {
    Write-Host "Last backup was created less than $days ago."
    }
}

Stop-Transcript
