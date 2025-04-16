#Requires -Modules Microsoft.Graph.Entra.Beta

<#
.SYNOPSIS
    Finds Entra Private Access applications that include segments matching a specified IP/FQDN, port, and protocol.

.DESCRIPTION
    This script takes an IP address or FQDN, a port number, and a protocol (TCP or UDP) as input,
    and returns all Entra Private Access applications that include application segments matching these criteria.
    It handles different segment types including FQDN, IP addresses, IP ranges, and CIDR subnets.

.PARAMETER DestinationHost
    The IP address or FQDN to search for.

.PARAMETER Port
    The port number to search for.

.PARAMETER Protocol
    The protocol to search for (TCP, UDP, or both).

.EXAMPLE
    .\Find-PrivateAccessApplicationSegment.ps1 -DestinationHost 10.1.1.55 -Port 3389 -Protocol TCP
    
.EXAMPLE
    .\Find-PrivateAccessApplicationSegment.ps1 -DestinationHost server.contoso.com -Port 22 -Protocol TCP

.NOTES
    This script requires the Microsoft.Graph.Entra module and appropriate permissions.
    Required permissions: NetworkAccessPolicy.ReadWrite.All, Application.ReadWrite.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DestinationHost,
    
    [Parameter(Mandatory = $true)]
    [int]$Port,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet("TCP", "UDP")]
    [string]$Protocol
)

# Function to check if an IP address is in a CIDR range
function Test-IpInCidr {
    param(
        [string]$Ip,
        [string]$CidrRange
    )
    
    # Split the CIDR range into the network address and the prefix length
    $cidrParts = $CidrRange -split '/'
    if ($cidrParts.Count -ne 2) {
        return $false
    }
    
    $networkAddress = $cidrParts[0]
    $prefixLength = [int]$cidrParts[1]
    
    # Convert the network address and the IP address to integers
    $networkAddressBytes = ([System.Net.IPAddress]::Parse($networkAddress)).GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($networkAddressBytes)
    }
    $networkAddressInt = [BitConverter]::ToUInt32($networkAddressBytes, 0)
    
    $ipBytes = ([System.Net.IPAddress]::Parse($Ip)).GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($ipBytes)
    }
    $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)
    
    # Calculate the subnet mask from the prefix length
    $mask = [UInt32]([math]::Pow(2, 32) - [math]::Pow(2, 32 - $prefixLength))
    
    # Check if the IP address is in the network range
    ($ipInt -band $mask) -eq ($networkAddressInt -band $mask)
}

# Function to check if an IP address is in an IP range (format: startIP..endIP)
function Test-IpInRange {
    param(
        [string]$Ip,
        [string]$IpRange
    )
    
    # Split the IP range into start and end IPs
    $rangeParts = $IpRange -split '\.\.'
    if ($rangeParts.Count -ne 2) {
        return $false
    }
    
    $startIp = $rangeParts[0]
    $endIp = $rangeParts[1]
    
    # Convert all IPs to integers for comparison
    $startIpBytes = ([System.Net.IPAddress]::Parse($startIp)).GetAddressBytes()
    $endIpBytes = ([System.Net.IPAddress]::Parse($endIp)).GetAddressBytes()
    $ipBytes = ([System.Net.IPAddress]::Parse($Ip)).GetAddressBytes()
    
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($startIpBytes)
        [Array]::Reverse($endIpBytes)
        [Array]::Reverse($ipBytes)
    }
    
    $startIpInt = [BitConverter]::ToUInt32($startIpBytes, 0)
    $endIpInt = [BitConverter]::ToUInt32($endIpBytes, 0)
    $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)
    
    # Check if the IP is within the range
    return ($ipInt -ge $startIpInt) -and ($ipInt -le $endIpInt)
}

# Function to check if a port is included in a port range (format: startPort-endPort)
function Test-PortInRange {
    param(
        [int]$Port,
        [string]$PortRange
    )
    
    # Process various port formats in segments
    if ($PortRange -match "^(\d+)-(\d+)$") {
        $startPort = [int]$Matches[1]
        $endPort = [int]$Matches[2]
        return ($Port -ge $startPort) -and ($Port -le $endPort)
    }
    elseif ($PortRange -match "^\d+$") {
        return $Port -eq [int]$PortRange
    }
    
    return $false
}

# Function to check if the protocol matches
function Test-ProtocolMatch {
    param(
        [string]$InputProtocol,
        [string]$SegmentProtocol
    )
    
    # Protocol can be "tcp", "udp", or "tcp,udp"
    $protocols = $SegmentProtocol -split ',' | ForEach-Object { $_.Trim().ToLower() }
    Write-Verbose "Comparing input protocol '$($InputProtocol.ToLower())' against segment protocols: [$($protocols -join ', ')]"
    return $protocols -contains $InputProtocol.ToLower()
}

# Function to check if a hostname matches a DNS suffix
function Test-HostnameMatchDnsSuffix {
    param(
        [string]$Hostname,
        [string]$DnsSuffix
    )
    
    return $Hostname -like "*.$DnsSuffix" -or $Hostname -eq $DnsSuffix
}

# Main logic
try {
    # Check if we are connected to Microsoft Graph with proper scopes
    $currentConnection = Get-MgContext
    if (-not $currentConnection) {
        Write-Host "Not connected to Microsoft Graph. Connecting now..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "NetworkAccessPolicy.ReadWrite.All", "Application.ReadWrite.All", "NetworkAccess.ReadWrite.All"
    }
    else {
        $requiredScopes = @("NetworkAccessPolicy.ReadWrite.All", "Application.ReadWrite.All", "NetworkAccess.ReadWrite.All")
        $missingScopes = $requiredScopes | Where-Object { $currentConnection.Scopes -notcontains $_ }
        if ($missingScopes) {
            Write-Host "Missing required scopes: $($missingScopes -join ', '). Reconnecting with proper scopes..." -ForegroundColor Yellow
            Connect-MgGraph -Scopes "NetworkAccessPolicy.ReadWrite.All", "Application.ReadWrite.All", "NetworkAccess.ReadWrite.All" -ForceRefresh
        }
    }

    # Define a custom object to store the results
    $matchingApps = @()

    # Get all Private Access applications
    Write-Host "Retrieving all Entra Private Access applications..." -ForegroundColor Cyan
    $applications = Get-EntraBetaPrivateAccessApplication
    Write-Host "Found $($applications.Count) Entra Private Access applications" -ForegroundColor Green

    # Determine if the input destination is an IP address or FQDN
    $isIpAddress = [bool]($DestinationHost -as [System.Net.IPAddress])
    
    # Process each application
    foreach ($app in $applications) {
        Write-Verbose "Processing application: $($app.DisplayName)"
        
        # Get all application segments for the current application
        $segments = Get-EntraBetaPrivateAccessApplicationSegment -ApplicationId $app.Id
        Write-Verbose "Found $($segments.Count) segments for application $($app.DisplayName)"
        
        # Process each segment to check if it matches the input criteria
        foreach ($segment in $segments) {
            $segmentMatched = $false
            
            # Check if the segment matches by protocol first
            $protocolMatched = Test-ProtocolMatch -InputProtocol $Protocol -SegmentProtocol $segment.Protocol
            if (-not $protocolMatched) {
                continue
            }
            
            # Check if the port matches
            $portMatched = $false
            if ($segment.Ports) {
                foreach ($portRange in $segment.Ports) {
                    if (Test-PortInRange -Port $Port -PortRange $portRange) {
                        $portMatched = $true
                        break
                    }
                }
            }
            elseif ($segment.Port -eq $Port -or $segment.Port -eq 0) {
                # Port 0 in a segment typically means "all ports"
                $portMatched = $true
            }
            
            if (-not $portMatched) {
                continue
            }
            
            # Check if the destination host matches
            if ($isIpAddress) {
                # Input is an IP address
                Write-Verbose "Comparing IP $DestinationHost with segment destinationType: $($segment.DestinationType), destinationHost: $($segment.DestinationHost)"
                switch ($segment.DestinationType) {
                    "ipAddress" {
                        $segmentMatched = ($DestinationHost -eq $segment.DestinationHost)
                    }
                    "ip" {
                        $segmentMatched = ($DestinationHost -eq $segment.DestinationHost)
                        Write-Verbose "IP match result: $segmentMatched"
                    }
                    "ipRange" {
                        $segmentMatched = (Test-IpInRange -Ip $DestinationHost -IpRange $segment.DestinationHost)
                    }
                    "ipRangeCidr" {
                        $segmentMatched = (Test-IpInCidr -Ip $DestinationHost -CidrRange $segment.DestinationHost)
                    }
                }
            }
            else {
                # Input is a hostname/FQDN
                switch ($segment.DestinationType) {
                    "fqdn" {
                        $segmentMatched = ($DestinationHost -eq $segment.DestinationHost)
                    }
                    "dnsSuffix" {
                        $segmentMatched = (Test-HostnameMatchDnsSuffix -Hostname $DestinationHost -DnsSuffix $segment.DestinationHost)
                    }
                }
            }
            
            # If all criteria matched, add this application to results
            if ($segmentMatched) {
                $matchingApps += [PSCustomObject]@{
                    ApplicationId = $app.Id
                    ApplicationName = $app.DisplayName
                    SegmentId = $segment.Id
                    SegmentType = $segment.DestinationType
                    SegmentHost = $segment.DestinationHost
                    SegmentPorts = $segment.Ports -join ", "
                    SegmentProtocol = $segment.Protocol
                }
                
                # We've found a match, so we can break out of the segment loop for this app
                break
            }
        }
    }
    
    # Return the results
    if ($matchingApps.Count -gt 0) {
        Write-Host "Found $($matchingApps.Count) matching application(s)" -ForegroundColor Green
        return $matchingApps
    }
    else {
        Write-Host "No matching applications found" -ForegroundColor Yellow
        return $null
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
