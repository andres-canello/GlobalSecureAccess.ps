$global:TenantID = $null
<#
.SYNOPSIS
    Connect the GlobalSecureAccess.ps module to the Entra tenant.
.DESCRIPTION
    This command will connect Microsoft.Graph to your Entra tenant.
    You can also directly call Connect-MgGraph if you require other options to connect

    Use the following scopes when authenticating with Connect-MgGraph.

    Connect-MgGraph -Scopes 'NetworkAccessPolicy.ReadWrite.All'

.EXAMPLE
    PS C:\>Connect-GSATenant
    Connect to home tenant of authenticated user.
.EXAMPLE
    PS C:\>Connect-GSATenant -TenantId 3043-343434-343434
    Connect to a specific Tenant
#>
function Connect-GSATenant {
    param(
        [Parameter(Mandatory = $false)]
            [string] $TenantId = 'common',
        [Parameter(Mandatory=$false)]
            [ArgumentCompleter( {
                param ( $CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters )
                (Get-MgEnvironment).Name
            } )]
            [string]$Environment = 'Global'
    )    
    Connect-MgGraph -TenantId $TenantId -Environment $Environment -Scopes 'NetworkAccessPolicy.ReadWrite.All', 
        'Directory.Read.All', 'Application.ReadWrite.All'

    Get-MgContext
    $global:TenantID = (Get-MgContext).TenantId
}