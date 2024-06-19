$csvFile = "C:\temp\AppSegments.csv"
 
# Assuming the CSV file has columns named 'clientID', 'iprange', 'ports', 'protocol', 'type'
$variables = Import-Csv $csvFile
 
# Loop through each row of the CSV and execute the command for each set of variables
foreach ($variable in $variables) {
    $clientID = $variable.clientID
    $iprange = $variable.iprange
    $ports = $variable.ports -split ","
    $protocol = $variable.protocol -split ","
    $type = $variable.type
 

    # Execute the command
    Get-GSAPrivateAccessApp $clientID | New-GSAPrivateAccessAppNetworkSegment -DestinationHost $iprange -Ports $ports -Protocol $protocol -DestinationType $type -debug
}