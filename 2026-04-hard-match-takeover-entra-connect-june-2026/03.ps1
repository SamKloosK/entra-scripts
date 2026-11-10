# From: https://www.argusit.nl/en/blog/hard-match-takeover-entra-connect-june-2026
# Section: Tenant settings you can switch on yourself
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "OnPremDirectorySynchronization.ReadWrite.All"

$OnPremSync = Get-MgDirectoryOnPremiseSynchronization
$OnPremSync.Features | Select-Object BlockCloudObjectTakeoverThroughHardMatchEnabled, BlockSoftMatchEnabled

$OnPremSync.Features.BlockCloudObjectTakeoverThroughHardMatchEnabled = $true
$OnPremSync.Features.BlockSoftMatchEnabled = $true
Update-MgDirectoryOnPremiseSynchronization `
    -OnPremisesDirectorySynchronizationId $OnPremSync.Id `
    -Features $OnPremSync.Features
