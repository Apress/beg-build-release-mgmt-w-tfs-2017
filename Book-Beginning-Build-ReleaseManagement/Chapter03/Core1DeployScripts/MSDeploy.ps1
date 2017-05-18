param($MSDeployPath, $package, $websiteName, $computerName, $deployUser, $deployUserPwd)

. "$MSDeployPath\msdeploy" -verb:sync -source:package=$package -dest:contentPath="$websiteName",computerName=$computerName,username=$deployUser,password=$deployUserPwd,AuthType="Basic" -enablelink:contentlibextension -enableRule:AppOffline -enableRule:DoNotDeleteRule -allowUntrusted

Write-Host "##vso[task.complete result=Succeeded;]DONE"