param(
    [Parameter(mandatory=$true)]
    [string]$UserName,
    [Parameter(mandatory=$true)]
    [string]$UserPwd,
    [Parameter(mandatory=$true)]
    [string]$CRMSvrUrl,
    [Parameter(mandatory=$true)]
    [string]$CRMOrgName,
    [Parameter(mandatory=$true)]
    [int]$CRMTimeout,
	[Parameter(Mandatory=$true)] 
    [String]$CRMSolutionName,
    [Parameter(Mandatory=$true)] 
    [String]$CRMSolutionExportMode
)

$ErrorActionPreference = "Stop"

#*********************** Functions

. "$PSScriptRoot\..\Utils\CommonFunctions.ps1"


#***********************************

#*********************Common Variables
$SolutionTempExportPath = "$PSScriptRoot\..\CRM\Solutions\tmp"
$SolutionExtractPath = "$PSScriptRoot\..\CRM\Solutions"
#***********************************


Import-Module "$PSScriptRoot\..\PSModules\Microsoft.Xrm.Data.PowerShell" -Verbose:$false

Write-Verbose "Connecting to $CRMOrgUrl ... "

$secpasswd = ConvertTo-SecureString $UserPwd -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($UserName, $secpasswd)

$crmcon = Get-CrmConnection -ServerUrl $CRMSvrUrl -OrganizationName $CRMOrgName -Credential $cred  -Verbose
#$crmcon.OrganizationServiceProxy.Timeout = New-TimeSpan -Seconds $CRMTimeout
Write-Verbose "CRM connection obtained."


CreateOrCleanDirectory -DirectoryPath $SolutionTempExportPath


if(($CRMSolutionExportMode -eq "Both") -or ($CRMSolutionExportMode -eq "Unmanaged"))
{
    Write-Verbose ("Exporting unmanaged CRM Solution {0} ..." -f  $CRMSolutionName) 
                
    Export-CrmSolution -conn $crmcon -SolutionName $CRMSolutionName -SolutionFilePath $SolutionTempExportPath -SolutionZipFileName ("{0}.zip" -f $CRMSolutionName) -Verbose
                
    Write-Verbose ("Exporting unmanaged completed for CRM Solution {0} ." -f  $CRMSolutionName)

    $ExtractFolderPath = $CRMSolutionName + "_unmanaged"
    $ExtractFolderPath = Join-Path $CRMSolutionName $ExtractFolderPath
    $ExtractFolderPath = Join-Path $SolutionExtractPath $ExtractFolderPath

    CreateOrCleanDirectory -DirectoryPath $ExtractFolderPath
            
    Write-Verbose ("Extracting unmanaged CRM Solution {0} to {1}..." -f  $CRMSolutionName, $ExtractFolderPath) 
    $zipFilePath = Join-Path $SolutionTempExportPath ("{0}.zip" -f $CRMSolutionName)
    UnzipFiles -zipfilename $zipFilePath -targetdir $ExtractFolderPath
    Write-Verbose ("Extracted unmanaged CRM Solution {0} to {1}." -f  $CRMSolutionName, $ExtractFolderPath) 
}
            
if(($CRMSolutionExportMode -eq "Both") -or ($CRMSolutionExportMode -eq "Managed"))
{
    Write-Verbose ("Exporting managed CRM Solution {0} ..." -f  $CRMSolutionName) 
                
    Export-CrmSolution -conn $crmcon -SolutionName $CRMSolutionName -SolutionFilePath $SolutionTempExportPath -SolutionZipFileName ("{0}_managed.zip" -f $CRMSolutionName) -Managed -Verbose
                
    Write-Verbose ("Exporting managed completed for CRM Solution {0} ." -f  $CRMSolutionName)

    $ExtractFolderPath = $CRMSolutionName + "_managed"
    $ExtractFolderPath = Join-Path $CRMSolutionName $ExtractFolderPath
    $ExtractFolderPath = Join-Path $SolutionExtractPath $ExtractFolderPath

    CreateOrCleanDirectory -DirectoryPath $ExtractFolderPath
            
    Write-Verbose ("Extracting managed CRM Solution {0} to {1}..." -f  $CRMSolutionName, $ExtractFolderPath) 
    $zipFilePath = Join-Path $SolutionTempExportPath ("{0}_managed.zip" -f $CRMSolutionName)
    UnzipFiles -zipfilename $zipFilePath -targetdir $ExtractFolderPath
    Write-Verbose ("Extracted managed CRM Solution {0} to {1}." -f  $CRMSolutionName, $ExtractFolderPath) 
}

            


Remove-Item $SolutionTempExportPath -recurse -Force
