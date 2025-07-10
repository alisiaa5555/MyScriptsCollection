/*
This is the script I wrote for application packaging purposes. Application required an extension to be installed in Edge. The script first checks if the path in the registry
exists and if yes, then it checks if the specific extension is added in the registry already. If not, the extension will be added. The output is logged to the file."
*/
$ApplicationName = "My application"
$ScriptTitle = "Add Edge Extension for $ApplicationName"
$Date = Get-Date
$logs = "c:/Logs/Extension.txt"
Start-Transcript -Path $logs 

Write-Host "$ScriptTitle"
Write-Host "$Date"

$Extension = "oneiddfjphkjapmkonkgbhpggldboeja" #Extension value. 

Write-Host "Extension's value: $Extension"

$regPath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" #Registry path

#Testing if path in the registry exists.
if (Test-Path -Path $regPath){
$getreg = Get-Item -Path $regPath

$PropName = $getreg.Property #Get Property Names like 1,2,3... and assign it to $PropName
Write-Host "Checking if property $Extension exists..."
Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
$exists = $false
           
foreach ($property in $PropName) {
      if ((Get-ItemProperty -Path $regPath -Name $property).$property -eq $Extension) {
      $exists = $true 
      break}}

      if (-not $exists) {
          $getPropertyNb = $getreg.Property
          $count1 = $getPropertyNb.Count
          $count1 = $count1+1
          New-ItemProperty -Path $regPath -Name $count1 -PropertyType String -Value $Extension
          Write-Host "$Extension has been added to the registry."} 
      else {
        Write-Host "The extension $Extension already exists in registry."}
}else{
Write-Host "Path $regPath doesn't exisits"
}
Stop-Transcript
