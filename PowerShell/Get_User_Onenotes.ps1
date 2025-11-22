Connect-MgGraph -Scopes "Notes.Read.All" #Connect to Microsoft Graph using delegated access, proving scope.
Import-module Microsoft.Graph.Notes #Import module needed to use commands for pulling out OneNote information.

$userId = "bbd7y590-XXXXXXXXXXXXXXxx" #User ID - required parameter for command Get-MgUserOnenotePage. Using this command it's possible to retrive onenote, it's sections and pages.
$pages = Get-MgUserOnenotePage -UserId $userId -ExpandProperty @("ParentNotebook","ParentSection")

<#
if we look into the properties using Get-member, we can see that it's possible to pull out properties like
ParentNotebook       Property              Microsoft.Graph.PowerShell.Models.IMicrosoftGraphNotebook ParentNotebook {get;set;}
ParentSection        Property              Microsoft.Graph.PowerShell.Models.IMicrosoftGraphOnenoteSection ParentSection {get;set;}
#>

$pages | Get-Member 

$pagesList = @() #declare an empty array to which we will assign Onenote details using the foreeach loop like: page Title, Notebook ID, it's display name as well as section ID and displaname
foreach ($page in $pages){
    $pagesList += [PSCustomObject]@{
    PageTitle          = $page.Title
    PageParentNotebookDisplayName = $page.ParentNotebook.DisplayName
    PageParentNotebookID = $page.ParentNotebook.Id
    PageParentSectionDisplayName  = $page.ParentSection.DisplayName
    PageParentSectionID  = $page.ParentSection.ID
    }
}

$pagesList | Format-Table -AutoSize #Diplay the output in the table.

Disconnect-MgGraph #Disconnect from Microsoft Graph
<#
OUTPUT:
PageTitle               PageParentNotebookDisplayName PageParentNotebookID                   PageParentSectionDisplayName PageParentSectionID
---------               ----------------------------- --------------------                   ---------------------------- ------------------- 
Blah                    secondTest                    1-c500cd75-b4fc-4a64-888c-792dfdcf8a5c SekcjasecondTest             1-523f8de9-e611-4e… 
Microsoft Graph OneNote TestOneNote                   1-77899746-5c51-45a3-b6af-e2746b9456f0 SekcjaTestOneNote            1-ed8e4a1a-be00-45… 
Test                    TestOneNote                   1-77899746-5c51-45a3-b6af-e2746b9456f0 SekcjaTestOneNote            1-ed8e4a1a-be00-45… 
#>
