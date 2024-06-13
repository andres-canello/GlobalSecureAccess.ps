function New-GSAPrivateAccessApp {
	<#
	.SYNOPSIS
	    Creates a new Private Access app.
	.DESCRIPTION
		Creates a new Private Access app.
	.EXAMPLE
	    PS C:\>New-GSAPrivateAccessApp
		
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessApp -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628
		Gets a single Private Access app.
	#>
	[CmdletBinding(DefaultParameterSetName = 'AllPrivateAccessApps')]
	param (

		[Parameter(Mandatory = $True, Position = 1)]
		[string]
		$AppName,
		
		[Parameter(Mandatory = $True)]
		[string]
		$ConnectorGroupID
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}


    $bodyJson = @{displayName = $AppName} | ConvertTo-Json -Depth 99 -Compress

	# Instantiate the Private Access app

	try {
		$newApp = Invoke-GSARequest -Method POST -Query https://graph.microsoft.com/beta/applicationTemplates/8adf8e6e-67b2-4cf2-a259-e3dc5476c621/instantiate -Body $bodyJson -Raw
	}
	catch {
		Write-Error "Failed to create the Private Access app. Error: $_"
		return
	}

	$bodyJson = @{
		"onPremisesPublishing" = @{
			"applicationType" = "nonwebapp"
			"isAccessibleViaZTNAClient" = $true
		}
	} | ConvertTo-Json -Depth 99 -Compress

	$newAppId = $newApp.application.objectId

	# Set the Private Access app to be accessible via the ZTNA client
	$params = @{
		Method = 'PATCH'
		Query = "https://graph.microsoft.com/beta/applications/$newAppId/"
		Body = $bodyJson

	}

	Invoke-GSARequest @params -Raw

	$bodyJson = @{
		"@odata.id" = "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationproxy/connectorGroups/$ConnectorGroupID"
	} | ConvertTo-Json -Depth 99 -Compress

	# Assigns the connector group to the app
	$params = @{
		Method = 'PUT'
		Query = "https://graph.microsoft.com/beta/applications/$newAppId/connectorGroup/`$ref"
		Body = $bodyJson

	}
		
}
