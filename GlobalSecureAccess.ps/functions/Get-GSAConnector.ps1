function Get-GSAConnector {
	<#
	.SYNOPSIS
	    Gets Private Access Connector.
	.DESCRIPTION
		Gets Private Access Connector.
	.EXAMPLE
	    PS C:\>Gets Private Access Connector.
		Gets Private Access Connector.

	#>
	[CmdletBinding(DefaultParameterSetName = 'AllConnectors')]
	param (
		[Parameter(Mandatory = $True, Position = 1, ParameterSetName = 'SingleConnector')]
		[string]
		$ConnectorID,

		[Alias('id')]
		[Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ConnectorGroup')]
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
		"AllConnectors" {
			Invoke-GSARequest @common -Query 'https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectors'
			break
		}			
		"SingleConnector" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectors/$ConnectorID" -Raw
			break
		}
		"ConnectorGroup" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/onPremisesPublishingProfiles/applicationProxy/connectorGroups/$ConnectorGroupID/members"
			break
		}
	}
	
}
