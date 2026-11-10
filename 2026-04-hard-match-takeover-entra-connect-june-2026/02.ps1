# From: https://www.argusit.nl/en/blog/hard-match-takeover-entra-connect-june-2026
# Section: Finding admin accounts with an anchor
# Read the post first and test in a non-production tenant.

$immutableId = '<onPremisesImmutableId from the report>'
$bytes = [Convert]::FromBase64String($immutableId)
$ldap  = ($bytes | ForEach-Object { '\{0:x2}' -f $_ }) -join ''
Get-ADObject -LDAPFilter "(mS-DS-ConsistencyGuid=$ldap)" -IncludeDeletedObjects -Properties whenChanged
