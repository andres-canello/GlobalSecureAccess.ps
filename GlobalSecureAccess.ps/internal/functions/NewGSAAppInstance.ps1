function NewGSAAppInstance {

    [CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$AppName
    )



    $bodyJson = @{displayName = $AppName} | ConvertTo-Json -Depth 99 -Compress

	try {
		$newApp = Invoke-GSARequest -Method POST -Query https://graph.microsoft.com/beta/applicationTemplates/8adf8e6e-67b2-4cf2-a259-e3dc5476c621/instantiate -Body $bodyJson -Raw
	}
	catch {
		Write-Error "Failed to create the Private Access app. Error: $_"
		return
	}

	if ($null -eq $newApp) {
		Write-Error "Failed to create Private Access app with error ."
		return
	}

	$apiResponse

}