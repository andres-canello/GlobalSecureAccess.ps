function Invoke-GSARequest
{
<#
	.SYNOPSIS
		Execute an arbitrary graph call against Graph endpoints.
	
	.DESCRIPTION
		Execute an arbitrary graph call against Graph endpoints.
		Handles authentication & token refresh transparently.
	
	.PARAMETER Query
		The actual query to execute.
	
	.PARAMETER Method
		The REST method to apply
	
	.PARAMETER Body
		Any body data to pass along as part of the request
	
	.PARAMETER Raw
		Get raw response
	
	.EXAMPLE
		PS C:\> Invoke-GSARequest -Query 'https://graph.microsoft.com/beta/users' -Method GET
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Query,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Method,
		
		$Body,
			
		[switch]
		$Raw
	)
	
	begin
	{

	}
	process
	{
        if ($Body) { 

            try { $response = Invoke-MgGraphRequest -Method $Method -Uri $Query -Body $Body -OutputType PSObject -ErrorAction Continue }
            catch { throw }

         }
         else {

            try { $response = Invoke-MgGraphRequest -Method $Method -Uri $Query -OutputType PSObject -ErrorAction Continue }
            catch { throw }
         }

		
		
		if ($Raw) { return $response }

		$response.Value
		
	}
}