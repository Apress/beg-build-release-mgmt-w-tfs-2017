
#--------------------------Zip and Extract----------------------

function ZipFiles( $zipfilename, $sourcedir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}

function UnzipFiles( $zipfilename, $targetdir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfilename, $targetdir)
}


#--------------------------CreateCleanDirectory----------------------

function CreateOrCleanDirectory($DirectoryPath)
{
    if ([IO.Directory]::Exists($DirectoryPath)) 
    { 
	    $DeletePath = $DirectoryPath + "\*"
	    Remove-Item $DeletePath -recurse -Force
		[IO.Directory]::CreateDirectory($DirectoryPath) | Out-Null
    } 
    else
    { 
	    [IO.Directory]::CreateDirectory($DirectoryPath) | Out-Null
	    
    } 
}

#------------------------------------------------------------------------------

#*******************************
#Restart Service

[System.Collections.ArrayList]$ServicesToRestart = @()

function Custom-GetDependServices ($ServiceInput)
{
	#Write-Host "Name of `$ServiceInput: $($ServiceInput.Name)"
	#Write-Host "Number of dependents: $($ServiceInput.DependentServices.Count)"
	If ($ServiceInput.DependentServices.Count -gt 0)
	{
		ForEach ($DepService in $ServiceInput.DependentServices)
		{
			#Write-Host "Dependent of $($ServiceInput.Name): $($Service.Name)"
			If ($DepService.Status -eq "Running")
			{
				#Write-Host "$($DepService.Name) is running."
				$CurrentService = Get-Service -Name $DepService.Name
				
                # get dependancies of running service
				Custom-GetDependServices $CurrentService                
			}
			Else
			{
				Write-Host "$($DepService.Name) is stopped. No Need to stop or start or check dependancies."
			}
			
		}
	}
    Write-Host "Service to Stop $($ServiceInput.Name)"
    if ($ServicesToRestart.Contains($ServiceInput.Name) -eq $false)
    {
        Write-Host "Adding service to stop $($ServiceInput.Name)"
        $ServicesToRestart.Add($ServiceInput.Name)
    }
}


function RestartServicesWithDependants($ServiceName)
{
    # Get the main service
    $Service = Get-Service -Name $ServiceName

    # Intialize Service List Array
    $ServicesToRestart = [System.Collections.ArrayList] @()

    # Get dependancies and stop order
    Custom-GetDependServices -ServiceInput $Service


    Write-Host "-------------------------------------------"
    Write-Host "Stopping Services"
    Write-Host "-------------------------------------------"
    foreach($ServiceToStop in $ServicesToRestart)
    {
        Write-Host "Stop Service $ServiceToStop"
        Stop-Service $ServiceToStop -Verbose #-Force
    }
    Write-Host "-------------------------------------------"
    Write-Host "Starting Services"
    Write-Host "-------------------------------------------"
    # Reverse stop order to get start order
    $ServicesToRestart.Reverse()

    foreach($ServiceToRestart in $ServicesToRestart)
    {
        Write-Host "Start Service $ServiceToRestart"
        Start-Service $ServiceToRestart -Verbose
    }
    Write-Host "-------------------------------------------"
    Write-Host "Restart of services completed"
    Write-Host "-------------------------------------------"

    sleep -Seconds 60
}
#*******************************

#***********************************
#JSON Deserialize
#---------------------------------------
# .NET JSON Serializer
	Add-Type -Assembly System.Web.Extensions 
    $global:javaScriptSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $global:javaScriptSerializer.MaxJsonLength = [System.Int32]::MaxValue
    $global:javaScriptSerializer.RecursionLimit = 100

    # Functions necessary to parse JSON output from .NET serializer to PowerShell Objects
    function ParseItem($jsonItem) {
            if($jsonItem.PSObject.TypeNames -match "Array") {
                    return ParseJsonArray($jsonItem)
            }
            elseif($jsonItem.PSObject.TypeNames -match "Dictionary") {
                    return ParseJsonObject([HashTable]$jsonItem)
            }
            else {
                    return $jsonItem
            }
    }

    function ParseJsonObject($jsonObj) {
            $result = New-Object -TypeName PSCustomObject
            foreach ($key in $jsonObj.Keys) {
                    $item = $jsonObj[$key]
                    if ($item) {
                            $parsedItem = ParseItem $item
                    } else {
                            $parsedItem = $null
                    }
                    $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
            }
            return $result
    }

    function ParseJsonArray($jsonArray) {
            $result = @()
            $jsonArray | ForEach-Object {
                    $result += , (ParseItem $_)
            }
            return $result
    }

    function ParseJsonString($json) {
            $config = $javaScriptSerializer.DeserializeObject($json)
            return ParseJsonObject($config)
    }
#***********************************