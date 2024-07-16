function Add-GSAConnectorToConnectorGroup {
	<#
	.SYNOPSIS
	    Adds a Connector to a Connector Group.
	.DESCRIPTION
		Adds a Connector to a Connector Group.
	.EXAMPLE
	    PS C:\>Add-GSAConnectorToConnectorGroup -ConnectorId b07a2b5d-38b3-41d7-aeee-4dc8c56154ea -ConnectorGroupId db6877f7-02e6-45d2-a986-c474d26d365c
		Adds a Connector to a Connector Group.
	.EXAMPLE
		PS C:\>Get-GSAConnector b07a2b5d-38b3-41d7-aeee-4dc8c56154ea | Add-GSAConnectorToConnectorGroup -ConnectorGroupId db6877f7-02e6-45d2-a986-c474d26d365c
		Adds a Connector to a Connector Group.
	#>

	param (

	[Alias('id')]
	[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
	[string]
	$ConnectorId,

	[Parameter(Mandatory = $True, Position = 2)]
	[string]
	$ConnectorGroupId

	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}
	

	$bodyJson = @{
		"@odata.id" = "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationproxy/connectorGroups/$ConnectorGroupId"
	} | ConvertTo-Json -Depth 99 -Compress

	$params = @{
		Method = 'PUT'
		Query = "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectors/$ConnectorId/memberOf/`$ref"
		Body = $bodyJson
	}
		
	
	try {
		Invoke-GSARequest @params -Raw
	}
	catch {
		Write-Error "Failed to add the Connector to the Connector Group. Error: $_"
		return
	}
	
}
