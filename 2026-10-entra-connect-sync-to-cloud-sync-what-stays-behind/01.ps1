# From: https://argusit.nl/en/blog/entra-connect-sync-to-cloud-sync-what-stays-behind
# Section: What to inventory before you start
# Read the post first and test in a non-production tenant.

# Run on the active Connect Sync server
Import-Module ADSync

$connectors = @{}
Get-ADSyncConnector | ForEach-Object { $connectors[$_.Identifier] = $_.Name }

$rules = Get-ADSyncRule

# Custom rules: no ImmutableTag
$rules | Where-Object { [string]::IsNullOrEmpty($_.ImmutableTag) } |
    Sort-Object Direction, Precedence |
    Select-Object Precedence, Direction, Name, LinkType, Disabled,
        SourceObjectType, TargetObjectType,
        @{ Name = 'Connector'; Expression = { $connectors[$_.Connector] } } |
    Export-Csv .\custom-sync-rules.csv -NoTypeInformation

# Out-of-box rules that were switched off, usually replaced by a clone
$rules | Where-Object { $_.ImmutableTag -and $_.Disabled } |
    Select-Object Precedence, Direction, Name
