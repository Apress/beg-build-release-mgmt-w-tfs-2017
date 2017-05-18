#
# DemoTask.ps1
#
[CmdletBinding(DefaultParameterSetName = 'None')]
param()

Write-Host "Starting DemoTask"
Trace-VstsEnteringInvocation $MyInvocation

try {

	
    $YourName               = Get-VstsInput -Name YourName -Require
    $ShowWarningMsg         = Get-VstsInput -Name ShowWarningMsg 
	$ShowErrorMsgandFail    = Get-VstsInput -Name ShowErrorMsgandFail 
    

	$compName = $env:COMPUTERNAME;

	Write-Host ("Hello from {0}, {1}" -f $compName, $YourName);

	if($ShowWarningMsg.ToLower() -eq "true")
	{
		Write-Warning ("Warnig message you requested from {0}, {1}" -f $compName, $YourName);
	}

	if($ShowErrorMsgandFail.ToLower() -eq "true")
	{
		Write-Error ("Error message you requested from {0}, {1}" -f $compName, $YourName);
	}

} catch {
	throw;
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending DemoTask"