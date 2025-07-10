/*
Script relates to the file called "AddEdgeExtensionInRegistry.ps1". I wrote it for uninstallation of the application purposes.
The script checks if the registry path exists. If yes, the script checks if the extension is added in the registry and removes the extension. Else, it returns information that extension doesn't exist in the registry.
The output is logged to the "RemoveExtension.txt" file.

$ApplicationName = "My application"
$ScriptTitle = "Remove Edge Extension for $ApplicationName"
$Date = Get-Date
$logs = "c:/Logs/RemoveExtension.txt"
Start-Transcript -Path $logs 

Write-Host "$ScriptTitle"
Write-Host "$Date"

$Extension = "oneiddfjphkjapmkonkgbhpggldboeja" #extension's value
Write-Host "Extension's value: $Extension"
#Testing if path in the registry exists.
if (Test-Path -Path $regPath){
            $regPath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" #registry path
            $getreg = Get-Item -Path $regPath -ErrorAction SilentlyContinue

            $PropName = $getreg.Property #Get Property Names like 1,2,3... and assign it to $PropName
            
             foreach ($property in $PropName) {
             if ((Get-ItemProperty -Path $regPath -Name $property).$property -eq $Extension){
             Remove-ItemProperty -path $regPath -name $property
             Write-Host "Extension removed."
             }}}
else{
Write-Host "Path $regPath doesn't exisits"
}
Write-Host "$Extension not in the registry."
Stop-Transcript
