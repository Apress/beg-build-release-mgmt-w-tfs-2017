[CmdletBinding()] Param (
[String]$mdfilePath,
[String]$SMTPServer,
[String]$SMTPPort,
[String]$Username,
[String]$Password,
[String]$EmailTo,
[String]$EmailSubject,
[String]$SkipTasks
)

#get the full path
$mdfullPath = Resolve-Path $mdfilePath

#Get Text
$mdt = [String]::Join([environment]::NewLine, (Get-Content $mdfullPath)); #Get-Content loses linebreaks for some reason.

$nl = [System.Environment]::NewLine
$mdtLines = $mdt.Split($nl)

$wiFound=$false;
$csFound=$false;
$csAtLeastOneRecord=$false;
$csHTML="";

$tabName = "WorkItemTable"

#Create Table object
$WorkItemTable = New-Object system.Data.DataTable “$tabName”

#Define Columns
$colWorkItemType1 = New-Object system.Data.DataColumn WorkItemType,([string])
$colId = New-Object system.Data.DataColumn Id,([int])
$colTitle = New-Object system.Data.DataColumn Title,([string])
$colState = New-Object system.Data.DataColumn State,([string])
$colAssignedTo = New-Object system.Data.DataColumn AssignedTo,([string])
$colWILink = New-Object system.Data.DataColumn WILink,([string])

#Add the Columns
$WorkItemTable.columns.add($colWorkItemType1)
$WorkItemTable.columns.add($colId)
$WorkItemTable.columns.add($colTitle)
$WorkItemTable.columns.add($colState)
$WorkItemTable.columns.add($colAssignedTo)
$WorkItemTable.columns.add($colWILink)

$buildNumber = ""
$sourceBranch = ""
foreach ($line in $mdtLines)
{
    # Obtain the Build Number 
    if ($line.StartsWith("**Build Number(s)**"))
    {
        $buildNumber += $line.Split(":")[1].Trim();
    }

    if ($line.StartsWith("**Source Branch(es)**"))
    {
        $sourceBranch += $line.Split(":")[1].Trim();
    }
    # Identify if we are at the WI section
    if ($line.StartsWith("###Associated work items "))
    {
        $wiFound = $true;
    }

    # Identify if we are at the ChangeSet section
    if ($line.StartsWith("###Associated change sets/commits"))
    {
        $csFound = $true;
        $csHTML = '<h2><u>Associated Changesets/Commits</u></h2><ul>';
    }


    # Work Items
    # If we are at the WI Section obtain only bugs and user stories
    if ($wiFound -and !$csFound)
    {
        if ($line.StartsWith("* **"))
        {
           

            # Adding associated work item 

            $wkLine = $line.Replace("* **",";").Replace("** [",";").Replace("] [",";").Replace("](",";").Replace(") [",";").Replace("]",";");
            $wkDetail = $wkLine.Split(";",[System.StringSplitOptions]::RemoveEmptyEntries);


            $workItemType = $wkDetail[0].Substring(0,$wkDetail[0].LastIndexOf(" "));

            if (($workItemType -ne "Task") -or ($SkipTasks.ToLower() -ne "true"))
            {

                #Create a row
                $row = $WorkItemTable.NewRow()

                #Enter data in the row
                $row.WorkItemType = $workItemType;
                $row.Id =  $wkDetail[0].Replace($workItemType,"").Trim();
                $row.Title =  $wkDetail[2];
                $row.State =  $wkDetail[1];
                $row.AssignedTo =  $wkDetail[4]; #.Replace("Assigned To: ","");
                $row.WILink = $wkDetail[3];

                #Add the row to the table
                $WorkItemTable.Rows.Add($row);
            }


        }
    }

    if($csFound)
    {   
        if ($line.StartsWith("* **"))
        {
            $csAtLeastOneRecord=$true;
            $csHTML = $csHTML + '<li style="font-family: Arial; font-size: 10pt;">' + $line.Replace("*","").Trim() + '</li>';
        }        
    }
}

if(!$csAtLeastOneRecord)
{
    $csHTML = $csHTML + '<li style="font-family: Arial; font-size: 10pt;">No Changesets/Commits found.</li>';
}
if($csFound)
{
    $csHTML = $csHTML + '</ul>';
}

$releaseHtml = $releaseHtml + '<h1><u>' + $EmailSubject + '</u><h1>'
$releaseHtml = $releaseHtml + '<h3>Build Number(s): ' + $buildNumber + '<h3>';
$releaseHtml = $releaseHtml + '<h3>Source Branch(es): ' + $sourceBranch + '<h3><br/>';
$releaseHtml = $releaseHtml + '<h2><u>Associated Work Items</u></h2>';

if ($WorkItemTable.Rows.Count -gt 0)
{
    $SortedWorkItems = ($WorkItemTable |sort WorkItemType,Id -Unique | Select-Object WorkItemType, Id, State, Title, AssignedTo, WILink)

    $tmpWkItemType="";
    foreach($workItem in $SortedWorkItems)
    {
        if($tmpWkItemType -ne $workItem.WorkItemType)
        {
            if($tmpWkItemType -eq "")
            {
                #$releaseHtml = $releaseHtml + '<br/>';
            }
            else
            {
                $releaseHtml = $releaseHtml + '</ul>';
            }

            
            $tmpWkItemType = $workItem.WorkItemType;

            $releaseHtml = $releaseHtml + '<h3>Work Item Type: ' + $workItem.WorkItemType + '</h3>';
            $releaseHtml = $releaseHtml + '<ul>';
        }
        $releaseHtml = $releaseHtml + '<li style="font-family: Arial; font-size: 10pt;">' + $workItem.State + ' <a href="' + $workItem.WILink + '" >' + $workItem.Id + " " + $workItem.Title + '</a> ' + $workItem.AssignedTo + '</li>';
    }

    $releaseHtml = $releaseHtml + '</ul>';
}
else
{
    $releaseHtml = $releaseHtml + '<ul><li style="font-family: Arial; font-size: 10pt;">No work items found.</li></ul>';
}

$releaseHtml = $releaseHtml + '<br/>' + $csHTML + '';

write-host $releaseHtml

write-host "Now sending email"

$message = New-Object System.Net.Mail.MailMessage
$message.subject = $EmailSubject
$message.IsBodyHtml = $true
$message.body = $releaseHtml

$recipients = $EmailTo.Split(";",[System.StringSplitOptions]::RemoveEmptyEntries);

foreach($recipient in $recipients)
{
	$message.to.add($recipient)
}
$message.from = $Username

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message)
write-host "Mail Sent"