function Get-GSAPrivateAccessAppNetworkSegment {
	<#
	.SYNOPSIS
	    Gets Private Access app network segments.
	.DESCRIPTION
		Gets Private Access app network segments.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessAppNetworkSegment -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628
		Gets all the network segments associated to an app.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessAppNetworkSegment 6e8e602b-466e-446c-99fa-ac4151748628 -NetworkSegmentID 05b319f5-1e5b-48f3-95b4-f78cf010fdbf
		Gets a specific network segment associated to an app.
	.EXAMPLE
	    PS C:\>Get-GSAPrivateAccessApp 6e8e602b-466e-446c-99fa-ac4151748628 | Get-GSAPrivateAccessAppNetworkSegment
		Gets all the network segments associated to an app from the pipeline.
	#>
	[CmdletBinding(DefaultParameterSetName = 'AllNetworkSegments')]
	param (

		[Alias('id')]
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$ObjectID,
		
		[Parameter(Mandatory = $False, Position = 2, ParameterSetName = 'SingleNetworkSegment')]
		[string]
		$NetworkSegmentID
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}

	$common = @{
		Method = 'GET'
	}



	switch ($PSCmdlet.ParameterSetName) {
		"AllNetworkSegments" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications/$ObjectID/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments"
			break
		}			
		"SingleNetworkSegment" {
			Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications/$ObjectID/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/$NetworkSegmentID" -Raw
			break
		}
	}
	
}
