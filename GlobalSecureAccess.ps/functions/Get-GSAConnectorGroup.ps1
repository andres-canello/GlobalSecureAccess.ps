function Get-GSAConnectorGroup {
	<#
	.SYNOPSIS
	    Gets Private Access Connector Group.
	.DESCRIPTION
		Gets Private Access Connector Group.
	.EXAMPLE
	    PS C:\>Get-GSAConnectorGroup
		Gets Private Access Connector Group.

	#>
	[CmdletBinding(DefaultParameterSetName = 'AllConnectorGroups')]
	param (
		[Parameter(Mandatory = $True, Position = 1, ParameterSetName = 'SingleConnectorGroup')]
		[string]
		$ConnectorGroupID
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}

	$common = @{
		Method = 'GET'
	}



	switch ($PSCmdlet.ParameterSetName) {
		"AllConnectorGroups" {
			Invoke-GSARequest @common -Query 'https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectorGroups'
			break
		}			
		"SingleConnectorGroup" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectorGroups/$ConnectorGroupID" -Raw
			break
		}
	}
	
}
