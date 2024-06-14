function New-GSAConnectorGroup {
	<#
	.SYNOPSIS
	    Creates a new Connector Group.
	.DESCRIPTION
		Creates a new Connector Group.
	.EXAMPLE
	    PS C:\>New-GSAConnectorGroup -Name "MyConnectorGroup"
		Creates a new connector group.
	#>

	param (

		[Parameter(Mandatory = $True, Position = 1)]
		[string]
		$Name
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}


    $bodyJson = @{Name = $Name} | ConvertTo-Json -Depth 99 -Compress

	# Create the connector group

	try {
		Invoke-GSARequest -Method POST -Query https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectorGroups -Body $bodyJson -Raw
	}
	catch {
		Write-Error "Failed to create the Connector Group. Error: $_"
		return
	}
	
}
