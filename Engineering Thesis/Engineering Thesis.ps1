
  <#
  This script was developed as part of my engineering thesis focused on automating employee creation using Microsoft Graph API and Jira.
  It automatically retrieves new employee data from .csv file, creates their Microsoft Entra ID accounts, assigns Entra groups and assigns roles—particularly for IT personnel.
  #>

  # Microsoft Entra Authorization
  $filePath = "C:\Users\...\File.txt"

  $file = Get-Content -Path $filePath
  $tenant = "XXXXXXXXXXXXXXX"
  $client_id = "XXXXXXXXXXXXXXX"
  $client_secret = "$file"

  $authUri = "https://login.microsoftonline.com/$tenant/oauth2/token"
  $authBody = "client_id=$client_id&client_secret=$client_secret&resource=https://graph.microsoft.com&grant_type=client_credentials"
  $AuthContentType = "application/x-www-form-urlencoded"

  $Result = Invoke-RestMethod -Uri $authUri -Body $authBody -Method Post -ContentType $AuthContentType
 
  $autHeader = @{"Authorization" = "$($Result.token_type) "+ "$($Result.access_token)"}
  $autHeader
  #Authorization based mainly on "https://petri.com/using-powershell-with-rest-apis/".

  function GetExisitingUsers($ExisitingUsers) {

$AllUsersURL = "https://graph.microsoft.com/beta/users/"

$allUsers = Invoke-RestMethod -Uri $AllUsersURL -Method "GET" -Headers $autHeader
$UsersValue = $allUsers.value 

$ExisitingUsers = @() 

foreach ($ExUser in $UsersValue){
    $ExisitingUsers += [PSCustomObject]@{
        UPN = $ExUser.userPrincipalName
        Mail = $ExUser.mail
        MailNickname = $ExUser.mailNickname
        EmployeeID = $ExUser.employeeId
        JobTitle = $ExUser.jobTitle
        ID = $ExUser.id
        DisplayName = $ExUser.displayName
        Department = $ExUser.department
}} 
$ExisitingUsers 
}



#Get information about new users and assign it to the array.
function ImportCsvUsers {
    $CsvPath = "C:\Users\...\New Employees\NewEmployees.csv"
    $NewUsersCsv = Import-Csv -Path $CsvPath
    $GetNewUser = @()
    
    foreach ($csvUser in $NewUsersCsv){
        $GetNewUser += [PSCustomObject]@{
            accountEnabled = $csvUser.accountEnabled
            givenName = $csvUser.givenName
            Surname = $csvUser.Surname
            forceChangePasswordNextSignIn = $csvUser.forceChangePasswordNextSignIn
            password = $csvUser.password
            jobTitle = $csvUser.jobTitle
            department = $csvUser.department
            employeeHireDate = $csvUser.employeeHireDate
            country = $csvUser.country
            City = $csvUser.City
            companyName = $csvUser.companyName
            SharesManagerWith = $csvUser.SharesManagerWith
            AdditionalComments = $csvUser.AdditionalComments
        }
    }
$GetNewUser
}

      $ExisitEmp = GetExisitingUsers($ExisitingUsers)

#JIRA API authorization
$fileJiraPath = "C:\Users\...\JiraFile.txt"
$apiUrl = "https://XXXXXX.atlassian.net/rest/api/3/issue"
$apiToken =  Get-Content -Path $fileJiraPath
$username = "XXXXXX" 
$AuthText = "$username"+ ":" + "$apiToken"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($AuthText)
$EncodedAuthText = [Convert]::ToBase64String($Bytes)
$EncodedAuthText

$authHeader = @{
    Authorization = "Basic " + $EncodedAuthText
    "Content-Type" = "application/json"
}

# Functions that create tasks in Jira in case of an error. 
function RaiseErrorJiraIssue {
  param (
    $neupn,
    $nejobtitle,
    $necity,
    $summary,
    $description
  )

$projectKey = "SUP" 
$issueType = "Task" 
$Citylabel = @("HelpDeskLondon", "HelpDeskWarsaw")
if ($necity -eq "Warsaw") {
  $label = $Citylabel[1]
}elseif ($city -eq "London") {
  $label = $Citylabel[0]
}


$JiraIssueBody = @{
    fields = @{
        project = @{
            key = $projectKey
        }
        summary = $summary
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{
                            type = "text"
                            text = $description
                        }
                    )
                }
            )
        }
        issuetype = @{
            name = $issueType
        }
        labels = @($label)
    }
} | ConvertTo-Json -Depth 10

$JiraIssueBody

$PostJiraIssue = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $authHeader -Body $JiraIssueBody
$PostJiraIssue
}


function RaiseJiraIssueDevices {
  param (
    $displayName,
    $label,
    $ID
  )


$projectKey = "SUP" 
$issueType = "Task" 
$summary = "New User $displayName, ID: $ID - Prepare laptop and/or mobile device" 
$description = "Please prepare laptop and mobile device (if necessary) for new employee $displayName, ID: $ID" 
$Citylabel = @("LocalITSupportLondon", "LocalITSupportWarsaw")
if ($c.City -eq "Warsaw") {
  $label = $Citylabel[1]
}elseif ($c.City -eq "London") {
  $label = $Citylabel[0]
}


$authHeader = @{
    Authorization = "Basic " + $EncodedAuthText
    "Content-Type" = "application/json"
}

$JiraIssueBody = @{
    fields = @{
        project = @{
            key = $projectKey
        }
        summary = $summary
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{
                            type = "text"
                            text = $description
                        }
                    )
                }
            )
        }
        issuetype = @{
            name = $issueType
        }
        labels = @($label)
    }
} | ConvertTo-Json -Depth 10

$JiraIssueBody

$PostJiraIssue = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $authHeader -Body $JiraIssueBody
$PostJiraIssue
}

function RaiseJiraIssueAdditionalInfo {
  param (
    $displayName,
    $label,
    $description,
    $ID
  )


$projectKey = "SUP" 
$issueType = "Task" 
$summary = "New User $displayName, ID: $ID - Additional information" 
$Citylabel = @("HelpDeskLondon", "HelpDeskWarsaw")
if ($c.City -eq "Warsaw") {
  $label = $Citylabel[1]
}elseif ($c.City -eq "London") {
  $label = $Citylabel[0]
}


$authHeader = @{
    Authorization = "Basic " + $EncodedAuthText
    "Content-Type" = "application/json"
}

$JiraIssueBody = @{
    fields = @{
        project = @{
            key = $projectKey
        }
        summary = $summary
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{
                            type = "text"
                            text = $description
                        }
                    )
                }
            )
        }
        issuetype = @{
            name = $issueType
        }
        labels = @($label)
    }
} | ConvertTo-Json -Depth 10

$JiraIssueBody

$PostJiraIssue = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $authHeader -Body $JiraIssueBody
$PostJiraIssue
}


# Function that gets information about existing users in Entra and assigns information about the last employee ID to the variable.
function GetEmployeeID($lastId) {
     $GetExisitEmp = GetExisitingUsers($ExisitingUsers)
     $emp = $GetExisitEmp.EmployeeID
     $Ids = @()
         foreach ($e in $emp){
             $Ids += [int]$e}
     
    $lastId = $Ids | Sort-Object -Bottom 1
    $lastId
}



<#
This part of the script creates new employees in Entra. 
Based on the  conditions, the script compares the following fields: UPN, mail nickname, and job title:
a) If all values matches an existing user, an error will be logged in Jira.
b) If UPN and mail nickname matches but the job title is different, a digit is added to the UPN and an extra letter from the first name is appended to the mail nickname to avoid duplication. 
c) If UPN and job title were different, but the mail nickname already exists, another letter from the first name is added to the mail nickname.
d) If none of the conditions are met, the new user is created in Entra.
#>
$GetLastId = GetEmployeeID($lastId)
$ExisitEmp = GetExisitingUsers($ExisitingUsers)
$transcriptPath = "C:\Users\...\Logs\CheckUsers.txt"
$errorPath = "C:\Users\...\Logs"
$GetNewUsers = ImportCsvUsers($GetNewUser)

    $NewUsersArray = @()
    $CreatedNewUsers = @()
    Start-Transcript -Path $transcriptPath -Append
    $PostNewUserError = $false
    foreach ($user in $GetNewUsers){
        $FirstName = $user.givenName
        $LastName = $user.Surname
        $displayName = $FirstName + " " + $LastName
        $GetLastId++ 
        $city = $user.City
        $jobTitle = $user.jobTitle
        
        [int]$d = 1
        $upn = $FirstName + "." + $LastName + "@654t16.onmicrosoft.com"
    
        [int]$f = 1
        $shn = $FirstName.Substring(0,$f)
        
    
        if ($LastName.Length -ge 5){
        $n = 5
        }else{
        $n = $LastName.Length}
        $shl = $LastName.Substring(0,$n)
    
        $mailNickname = $shl + $shn
    
        $userAdded = $false 
    
        foreach ($em in $ExisitEmp){
                
                if (($upn -eq $em.UPN) -and ($mailNickname -eq $em.MailNickname) -and ($jobTitle -eq $em.JobTitle)){
                    
                    Write-Host "CSV Mailnickname $mailNickname -eq exisiting mailnickname $($em.MailNickname)" 
                    Write-Host "User with mail: $($em.UPN) and job title: $($em.JobTitle) already exists. Ticket in Jira will be raised 
                    for manual process" 
                    $summary = "Create new user $upn - Error occured while creating an employee" 
                    $description = "User with mail: $upn and job title: $jobTitle already exists. Please process the user manually"
                    RaiseErrorJiraIssue -neupn $upn -nejobtitle $jobTitle -necity $city -description $description -summary $summary
                    $userAdded = $true
                    break
                    
                }elseif (($upn -eq $em.UPN) -and ($mailNickname -eq $em.MailNickname) -and ($jobTitle -ne $em.JobTitle)) {
                    Write-Host "CSV Mailnickname $mailNickname -eq exisiting mailnickname $($em.MailNickname) "
                    Write-Host "Different user with MailNickname: $($em.MailNickname) and UPN $($em.UPN) already exists but different jobtitle than $($em.jobTitle). Adding additional letter to new mailnickname: $mailNickname and digit to UPN: $upn." 
                    $f++
                    $shn = $FirstName.Substring(0,$f)
                    $mailNickname = $shl + $shn
                    
                    $upn = $FirstName + "." + $LastName + $d + "@654t16.onmicrosoft.com"
                    Write-Host "completely new nickanme $mailNickname and UPN $upn" 
                    
                    $NewUsersArray += [PSCustomObject]@{
                        accountEnabled = $user.accountEnabled
                        givenName    = $FirstName
                        Surname     = $LastName
                        displayName  = $displayName
                        mailNickname = $mailNickname
                        userPrincipalName = $upn
                        mail = $upn
                        forceChangePasswordNextSignIn = $user.forceChangePasswordNextSignIn
                        password = $user.password
                        jobTitle     = $jobTitle
                        department = $user.department
                        employeeId = $GetLastId
                        employeeHireDate = $user.employeeHireDate
                        country = $user.country
                        City = $user.City
                        officeLocation = $user.City
                        companyName = $user.companyName
                        SharesManagerWith = $user.SharesManagerWith
                        AdditionalComments = $user.AdditionalComments
                    }
                   
                    $userAdded = $true
                    break
                }elseif (($upn -ne $em.UPN) -and ($jobTitle -ne $em.JobTitle) -and ($mailNickname -eq $em.MailNickname)) {
                    Write-Host "CSV Mailnickname $mailNickname -eq exisiting mailnickname $($em.MailNickname) but different UPN $upn  and different jobtitle: $jobTitle " 
                    Write-Host "Different user with MailNickname: $($em.MailNickname) already exists. Adding additional letter to new mailnickname: $mailNickname." 
                    $f++
                    $shn = $FirstName.Substring(0,$f)
                    $mailNickname = $shl + $shn
                    Write-Host "completely new nickanme $mailNickname" 
                    $NewUsersArray += [PSCustomObject]@{
                        accountEnabled = $user.accountEnabled
                        givenName    = $FirstName
                        Surname     = $LastName
                        displayName  = $displayName
                        mailNickname = $mailNickname
                        userPrincipalName = $upn
                        mail = $upn
                        forceChangePasswordNextSignIn = $user.forceChangePasswordNextSignIn
                        password = $user.password
                        jobTitle     = $jobTitle
                        department = $user.department
                        employeeId = $GetLastId
                        employeeHireDate = $user.employeeHireDate
                        country = $user.country
                        City = $user.City
                        officeLocation = $user.City
                        companyName = $user.companyName
                        SharesManagerWith = $user.SharesManagerWith
                        AdditionalComments = $user.AdditionalComments
                    }
                    
                    $userAdded = $true
                    break
                } 
                
            } 
            if (-not $userAdded) {
                $NewUsersArray += [PSCustomObject]@{
                    accountEnabled = $user.accountEnabled
                    givenName    = $FirstName
                    Surname     = $LastName
                    displayName  = $displayName
                    mailNickname = $mailNickname
                    userPrincipalName = $upn
                    mail = $upn
                    forceChangePasswordNextSignIn = $user.forceChangePasswordNextSignIn
                    password = $user.password
                    jobTitle     = $jobTitle
                    department = $user.department
                    employeeId = $GetLastId
                    employeeHireDate = $user.employeeHireDate
                    country = $user.country
                    City = $user.City
                    officeLocation = $user.City
                    companyName = $user.companyName
                    SharesManagerWith = $user.SharesManagerWith
                    AdditionalComments = $user.AdditionalComments
                }
            }
        }
    
    $NewUsersArray
    
    foreach ($nus in $NewUsersArray){
        try {
          
        $NewUser = @"
    {
                "accountEnabled": $($nus.accountEnabled),
                "givenName" : "$($nus.givenName)",
                "Surname" : "$($nus.Surname)",
                "displayName": "$($nus.displayName)",
                "mailNickname": "$($nus.mailNickname)",
                "userPrincipalName": "$($nus.userPrincipalName)",
                "mail": "$($nus.userPrincipalName)",
                "passwordProfile" : {
                    "forceChangePasswordNextSignIn": "$($nus.forceChangePasswordNextSignIn)",
                    "password": "$($nus.password)"
                                    },
                "jobTitle" : "$($nus.jobTitle)",
                "department" : "$($nus.department)",
                "employeeId" : "$($nus.employeeId)",
                "employeeHireDate" : "$($nus.employeeHireDate)",
                "country" : "$($nus.country)",
                "City" : "$($nus.City)",
                "officeLocation" : "$($nus.City)",
                "companyName" : "$($nus.companyName)"
                }
"@
        
        Write-Host "new user $NewUser"
        $PostUserUrl = "https://graph.microsoft.com/beta/users"
        $PostUser = Invoke-RestMethod -Uri $PostUserUrl -Body $NewUser -Headers $autHeader -Method Post -ContentType 'application/json'  
        }
        catch {
            Write-Error "Unable to post user with UPN: $($nus.userPrincipalName), MailNickname: $($nus.mailNickname), jobTitle: $($nus.jobTitle), department: $($nus.department), country: $($nus.country)" | Out-File "C:\Users\...\Logs\PostUserErrorLog.txt" -Append
            $Error | Out-File "$errorPath\PostUserErrorLog.txt" -Append
            $PostNewUserError = $true
            $City = $($nus.City)
            if ($PostNewUserError -eq $true){
              $summary = "Create new user $($nus.userPrincipalName) - Error occured while creating an employee" 
              $description = "User with mail: $($nus.userPrincipalName) and job title: $($nus.jobTitle) already exists. Please process the user manually"
              RaiseErrorJiraIssue -neupn $($nus.userPrincipalName) -nejobtitle $($nus.jobTitle) -necity $City -description $description -summary $summary
            }  
        }
    $CreatedNewUsers += [PSCustomObject]@{
        displayName = $PostUser.displayName
        ID = $PostUser.id
        UPN = $PostUser.userPrincipalName
        JobTitle = $PostUser.jobTitle 
        City = $PostUser.city                            
        Department = $PostUser.department
        SharesManagerWith = $nus.SharesManagerWith
        AdditionalComments = $nus.AdditionalComments
    }
    }  S

    $CreatedNewUsers
    Stop-Transcript


foreach ($c in $CreatedNewUsers){
  if ($PostNewUserError -eq $false){
  $displayName = $c.displayName
  $description = $c.AdditionalComments
  $ID = $c.ID
  RaiseJiraIssueDevices -displayName  $displayName -label $label -ID $ID
  RaiseJiraIssueAdditionalInfo -displayName  $displayName -label $label -description $c.AdditionalComments -ID $ID
  }
}


$GetRolesUri = "https://graph.microsoft.com/beta/directoryRoles"
$allRoles = Invoke-RestMethod -Uri $GetRolesUri -Method GET -Headers $autHeader -ContentType 'application/json'
$RoleValue = $allRoles.value 

#Bewlo functions assign roles to IT members based on their job title.
function AssignHelpDeskRoles {
  
  $HelpDeskRoles = @()
  $HelpDeskRoleNames = @("Printer Technician", "Directory Readers", "Global Reader", "Groups Administrator")
  
  foreach ($role in $RoleValue){
    for ($i = 0; $i -lt $HelpDeskRoleNames.Count; $i++){
    if ($role.displayName -eq $HelpDeskRoleNames[$i]){
    $HelpDeskRoles += [PSCustomObject]@{
    RoleName = $role.displayName
    RoleId = $role.Id}}
  }
  }
  
    for ($i = 0; $i -lt $HelpDeskRoles.Count; $i++){
      try {
      $RoleBody = @"
  {
      "@odata.type": "#microsoft.graph.unifiedRoleAssignment",
      "principalId": "$userId",
      "roleDefinitionId": "$($HelpDeskRoles.RoleId[$i])",  
      "directoryScopeId": "/" 
  }
"@
  
  $URI = "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments"
  $AssignRole = Invoke-RestMethod -Uri $URI -Method POST -Body $RoleBody -Headers $autHeader -ContentType 'application/json'
  $AssignRole
  }
  catch {
      Write-Error "Unable to assign Helpdesk role $($HelpDeskRoles.RoleId[$i]) to the user: $userId"
      $error | Out-File "$errorPath\AssignRolesErrorLog.txt" -Append
      #Jira task error:
      $summary = "Unable to assign roles to $NewUserUPN, ID: $userId - Error occured while creating an employee" 
      $description = "Unable to assign roles: $($role.displayName),  User ID: $userId. Please process the user manually"
      RaiseErrorJiraIssue -neupn $NewUserUPN -nejobtitle $jobTitle -necity $city -summary $summary -description $description
  }}
  }
  
  
  function AssignAdminRoles {
   
  $AdminRoles = @()
  $AdminRolesNames = @("Intune Administrator", "Directory Readers", "Global Reader", "Groups Administrator", "Authentication Administrator", "Global Administrator", "Teams Administrator", "Edge Administrator")
  
  foreach ($role in $RoleValue){
    for ($i = 0; $i -lt $AdminRolesNames.Count; $i++){
    if ($role.displayName -eq $AdminRolesNames[$i]){
      $AdminRoles += [PSCustomObject]@{
    RoleName = $role.displayName
    RoleId = $role.Id}}
  }
  }
    
    for ($i = 0; $i -lt $AdminRoles.Count; $i++){
      try {
      $RoleBody = @"
  {
      "@odata.type": "#microsoft.graph.unifiedRoleAssignment",
      "principalId": "$userId",
      "roleDefinitionId": "$($AdminRoles.RoleId[$i])",  
      "directoryScopeId": "/" 
  }
"@
  
  $URI = "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments"
  $AssignRole = Invoke-RestMethod -Uri $URI -Method POST -Body $RoleBody -Headers $autHeader -ContentType 'application/json'
  $AssignRole
  }
  catch {
    Write-Error "Unable to assign Admin role $($AdminRoles.RoleId[$i]) to the user: $userId"
    $error | Out-File "$errorPath\AssignRolesErrorLog.txt" -Append
     $summary = "Unable to assign roles to $NewUserUPN, ID: $userId - Error occured while creating an employee" 
     $description = "Unable to assign roles: $($role.displayName),  User ID: $userId. Please process the user manually"
     RaiseErrorJiraIssue -neupn $NewUserUPN -nejobtitle $jobTitle -necity $city -summary $summary -description $description
  }}
  }
  
  function AssignDevopsRoles {
   
  $DevOpsRoles = @()
  $DevOpsRolesNames = @("Intune Administrator", "Directory Readers", "Global Reader", "Groups Administrator", "Global Administrator", "Teams Administrator", "Azure DevOps Administrator")
  
  foreach ($role in $RoleValue){
    for ($i = 0; $i -lt $DevOpsRolesNames.Count; $i++){
    if ($role.displayName -eq $DevOpsRolesNames[$i]){
    $DevOpsRoles += [PSCustomObject]@{
    RoleName = $role.displayName
    RoleId = $role.Id}}
  }
  }
  
  
    for ($i = 0; $i -lt $DevOpsRoles.Count; $i++){
      try {
      $RoleBody = @"
  {
      "@odata.type": "#microsoft.graph.unifiedRoleAssignment",
      "principalId": "$userId",
      "roleDefinitionId": "$($DevOpsRoles.RoleId[$i])",  
      "directoryScopeId": "/" 
  }
"@
  
  $URI = "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments"
  $AssignRole = Invoke-RestMethod -Uri $URI -Method POST -Body $RoleBody -Headers $autHeader -ContentType 'application/json'
  $AssignRole
  }
  catch {
    Write-Error "Unable to assign Devops role $($DevOpsRoles.RoleId[$i]) to the user: $userId"
    $error | Out-File "$errorPath\AssignRolesErrorLog.txt" -Append
    
     $summary = "Unable to assign roles to $NewUserUPN, ID: $userId - Error occured while creating an employee" 
     $description = "Unable to assign roles: $($role.displayName), User ID: $userId. Please process the user manually"
     RaiseErrorJiraIssue -neupn $NewUserUPN -nejobtitle $jobTitle -necity $city -summary $summary -description $description
  }}
  }

  function AssignManagerRoles {
   
  $ManagerRoles = @()
  $ManagerRolesNames = @("Directory Readers", "Global Reader")
  
  foreach ($role in $RoleValue){
    for ($i = 0; $i -lt $ManagerRolesNames.Count; $i++){
    if ($role.displayName -eq $ManagerRolesNames[$i]){
    $ManagerRoles += [PSCustomObject]@{
    RoleName = $role.displayName
    RoleId = $role.Id}}
  }
  }
  
  
    for ($i = 0; $i -lt $ManagerRoles.Count; $i++){
      try {
      $RoleBody = @"
  {
      "@odata.type": "#microsoft.graph.unifiedRoleAssignment",
      "principalId": "$userId",
      "roleDefinitionId": "$($ManagerRoles.RoleId[$i])",  
      "directoryScopeId": "/" 
  }
"@
  
  $URI = "https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments"
  $AssignRole = Invoke-RestMethod -Uri $URI -Method POST -Body $RoleBody -Headers $autHeader -ContentType 'application/json'
  $AssignRole
  }
  catch {
    Write-Error "Unable to assign Manager role $($ManagerRoles.RoleId[$i]) to the user: $userId"
    $error | Out-File "$errorPath\AssignRolesErrorLog.txt" -Append
 #Jira task error:
 $summary = "Unable to assign roles to $NewUserUPN, ID: $userId - Error occured while creating an employee" 
 $description = "Unable to assign roles: $($role.displayName), User ID: $userId. Please process the user manually"
 RaiseErrorJiraIssue -neupn $NewUserUPN -nejobtitle $jobTitle -necity $city -summary $summary -description $description
  }}
  }
  
foreach ($mem in $CreatedNewUsers){
  $NewUserUPN = $($mem.UPN)
  $city = $($mem.City)
  $userId = "$($mem.id)"
  $jobTitle = "$($mem.jobTitle)"

if ($jobTitle -like "*IT Support Analyst"){
  AssignHelpDeskRoles
}elseif ($jobTitle -like "*IT Administrator"){
  AssignAdminRoles
}elseif ($jobTitle -like "*IT Developer"){
  AssignDevopsRoles
}elseif (($jobTitle -like "*IT Director") -or ($jobTitle -like "*IT Manager") -or ($jobTitle -eq "IT HelpDesk Team Leader")){
  AssignManagerRoles
}
}


$GetGroupsURL = "https://graph.microsoft.com/beta/groups/"
$GetGroups = Invoke-RestMethod -Uri $GetGroupsURL -Headers $autHeader -Method GET -ContentType 'application/json'
$GetGroups.value | Select-Object displayName, groupTypes, mailEnabled, securityEnabled
$groupsArray = @() #Zainicjowanie pustej tablicy, do której dodamu grupy po nazwie wyświetlanej wraz z ID
foreach ($gr in $GetGroups.value){
    $groupsArray += [PSCustomObject]@{
        displayName = $gr.displayName
        id = $gr.Id
        groupTypes = $gr.groupTypes
        mailEnabled = $gr.mailEnabled
        securityEnabled = $gr.securityEnabled
    }
}

#This function and assosiated loop below add users to the groups in Entra ID based on their location and department.
function Add-MemberToAGroup {
    <#
    .DESCRIPTION
    Function that add users to assigned groups in azure. Required parameter -$GroupDisplayName.
    #>
    param (
        $GroupDisplayName
    )
    try {
        $selectedGroup = $groupsArray | Select-Object displayName, id | Where-Object {$_.displayName -eq "$GroupDisplayName"}
        $GroupID = $($selectedGroup.id) 
        $UserID = $($mem.id) 
        $GroupsURL = "https://graph.microsoft.com/beta/groups/$GroupID/members/`$ref"

        $params= @"
        {
                "@odata.id": "https://graph.microsoft.com/beta/directoryObjects/$UserID"
        }
"@ 
        $AddMember = Invoke-RestMethod -Uri $GroupsURL -Body $params -Headers $autHeader -Method post -ContentType 'application/json'        
        $AddMember 
    }
    catch {
        Write-Error "User: $UserID already exisits in the group $GroupID"
    }  
}


#This function raises an issue in Jira in case of an error occured during group assigment process.
function RaiseJiraIssueGroups {
  param (
    $UPN,
    $City,
    $summary,
    $description
  )

$Citylabel = @("HelpDeskLondon", "HelpDeskWarsaw")
if ($membCity -eq "Warsaw") {
  $label = $Citylabel[1]
}elseif ($membCity -eq "London") {
  $label = $Citylabel[0]
}

$AuthText = "$username"+ ":" + "$apiToken"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($AuthText)
$EncodedAuthText = [Convert]::ToBase64String($Bytes)
$EncodedAuthText

$authHeader = @{
    Authorization = "Basic " + $EncodedAuthText
    "Content-Type" = "application/json"
}

$JiraIssueBody = @{
    fields = @{
        project = @{
            key = $projectKey
        }
        summary = $summary
        description = @{
            type = "doc"
            version = 1
            content = @(
                @{
                    type = "paragraph"
                    content = @(
                        @{
                            type = "text"
                            text = $description
                        }
                    )
                }
            )
        }
        issuetype = @{
            name = $issueType
        }
        labels = @($label)
    }
} | ConvertTo-Json -Depth 10

$JiraIssueBody

$PostJiraIssue = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $authHeader -Body $JiraIssueBody
$PostJiraIssue
}

foreach ($mem in $CreatedNewUsers){
    
    if (($mem.city -eq "London") -and ($mem.department -eq "IT")){
        $GroupDisplayName = "All-IT-London"
        Add-MemberToAGroup -GroupDisplayName $GroupDisplayName 
    }elseif (($mem.city -eq "London") -and ($mem.department -eq "Marketing")) {
        $GroupDisplayName = "All-Marketing-London"
        Add-MemberToAGroup -GroupDisplayName $GroupDisplayName
    }elseif (($mem.city -eq "Warsaw") -and ($mem.department -eq "IT")) {
        $GroupDisplayName = "All-IT-Warsaw"
        Add-MemberToAGroup -GroupDisplayName $GroupDisplayName
     }elseif (($mem.city -eq "Warsaw") -and ($mem.department -eq "Marketing")) {
        $GroupDisplayName = "All-Marketing-Warsaw"
        Add-MemberToAGroup -GroupDisplayName $GroupDisplayName
    }else{
        Write-Host "User: $mem does not meet requirements to be added to the specified groups."
    }
}


foreach ($mem in $CreatedNewUsers){
  $upn = $mem.UPN
  $membCity = $mem.City
  $ID = $mem.ID
  $DLHelpDesk = "DL-IT-HelpDesk"
  $DLMArketing = "DL-Marketing"
  if (($mem.JobTitle -like "*IT Support*") -or ($mem.JobTitle -like "*IT Help Desk*")) {
    Write-Host "$($mem.displayName) job: $($mem.JobTitle) - create jira ticket to add user to the group $DLHelpDesk"
    $summary = "New User $upn, ID: $ID - groups" 
    $description = "Please assign group: $DLHelpDesk manually to the user $upn, User ID: $ID"
    RaiseJiraIssueGroups -UPN $upn  -City $membCity -description $description -summary $summary
  }elseif ($mem.JobTitle -like "*Marketing*") {
    Write-Host "$($mem.displayName) job: $($mem.JobTitle)  - create jira ticket to add user to the group $DLMArketing"
    $summary = "New User $upn, ID: $ID - groups" 
    $description = "Please assign group: $DLMArketing manually to the user $upn, User ID: $ID"
    RaiseJiraIssueGroups -UPN $upn  -City $membCity -description $description -summary $summary
  }
}




$ExisitEmp = GetExisitingUsers($ExisitingUsers)
$ExisitingManagersID = @()

#Loop that assigns managers.
foreach ($exempl in $ExisitEmp){

 
    $userID = $exempl.ID
    $userID
    $GetUser = "https://graph.microsoft.com/beta/users/$userID/?`$expand=manager" 
    $userProp = Invoke-RestMethod -Uri $GetUser -Headers $autHeader -Method GET
  foreach ($usProp in $userProp){
    
    if ($usProp.manager -ne $null){
        $userUPN = $usProp.userPrincipalName
        $usersID = $usProp.id
        $assignedManagerUPN = $usProp.manager.userPrincipalName
        $ManagerID = $usProp.manager.id

        $ExisitingManagersID+= [PSCustomObject]@{
            User = $userUPN
            UserID = $usersID
            Manager = $assignedManagerUPN
            ManagerID = $ManagerID
        } 
  }
}}
$ExisitingManagersID | ft -AutoSize

$assignManagerPath = "C:\Users\...\Logs\AssignManager.txt"
Start-Transcript -Path $assignManagerPath -Append
foreach ($createduser in $CreatedNewUsers){
  $checkedUser = $false 
  $UPN = $createduser.UPN
  $ID = $createduser.ID
  $jobTitle = $createduser.JobTitle
  $city = $createduser.City
  foreach ($ex in $ExisitingManagersID){
    if ($($createduser.SharesManagerWith) -eq $ex.user) {
      $managerID = $ex.ManagerID
      $managerUPN = $ex.Manager
      $newUserID = $createduser.ID
      Write-Host "$($createduser.upn) shares manager with $($createduser.SharesManagerWith) and should have the following manager assigned: $managerUPN"

      $ManInfo= @"
{
        "@odata.id": "https://graph.microsoft.com/beta/users/$managerID"
}
"@

$ManUri = "https://graph.microsoft.com/beta/users/$newUserID/manager/`$ref"
$PutUser = Invoke-RestMethod -Uri $ManUri -Body $ManInfo -Headers $autHeader -Method Put -ContentType 'application/json'
      $checkedUser = $true
      break
    }
  }
  if (-not $checkedUser) {
    Write-Host "$($createduser.upn) has no manager provided. Ticket in jira will be raised for manual check"
    $summary = "Create new user $UPN, ID: $ID   - Error occured while adding manager" 
    $description = "User with mail: $UPN and ID: $ID has no manager provided. Please confirm with HR manager's name."
    RaiseErrorJiraIssue -neupn $UPN -nejobtitle $jobTitle -necity $city -description $description -summary $summary
  }
}
Stop-Transcript

