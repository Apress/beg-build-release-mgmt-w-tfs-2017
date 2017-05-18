param(
$CRMSolutionsRootPath,
$CRMSolutionName
)

$ErrorActionPreference = "Stop"


#resolve path to make sure no VB script errors
$CRMSolutionsRootPath = Resolve-Path $CRMSolutionsRootPath


$SolutionContainerPath = Join-Path $CRMSolutionsRootPath $CRMSolutionName
$SolutionContainerPathInfo = New-Object System.IO.DirectoryInfo $SolutionContainerPath
$SolutionDirectories = $SolutionContainerPathInfo.GetDirectories(); 

foreach($SolutionDirName in $SolutionDirectories)
{

    $zipFileName = "$CRMSolutionsRootPath\$SolutionDirName.zip"
    $foldertozip = "$SolutionContainerPath\$SolutionDirName"
                    
    #& CScript  zip.vbs $foldertozip $zipFileName | out-null
    & $PSScriptRoot\zipjs.bat zipDirItems -source $foldertozip -destination $zipFileName -keep yes -force no | out-null
}
