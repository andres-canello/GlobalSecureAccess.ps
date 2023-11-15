function Remove-GSAPrivateAccessAppNetworkSegment {
	<#
	.SYNOPSIS
	    Removes Private Access app network segments.
	.DESCRIPTION
		Removes a Private Access app network segment.
	.EXAMPLE
	    PS C:\>Remove-GSAPrivateAccessAppNetworkSegment -ObjectID 6e8e602b-466e-446c-99fa-ac4151748628 -NetworkSegmentID 6e8e602b-466e-446c-99fa-ac4151748611
		Removes a Private Access app network segment.
	#>
	[CmdletBinding()]
	param (


		[Parameter(Mandatory = $True, Position = 1)]
		[string]
		$ObjectID,
		
		[Parameter(Mandatory = $False, Position = 2)]
		[string]
		$NetworkSegmentID
	)


	if ($null -eq (Get-MgContext)) {
		Write-Error "No active connection. Run Connect-GSATenant or Connect-MgGraph to sign in and then retry."
		Exit-PSSession
	}

	$common = @{
		Method = 'DELETE'
	}


	Invoke-GSARequest @common -Query "https://graph.microsoft.com/beta/applications/$ObjectID/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments/$NetworkSegmentID" -Raw

}
