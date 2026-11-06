# From: https://argusit.nl/en/blog/entra-connect-sync-to-cloud-sync-what-stays-behind
# Section: What to inventory before you start
# Read the post first and test in a non-production tenant.

Get-ADGroup -Filter * -SearchBase 'OU=Pilot,DC=contoso,DC=com' -Properties 'mS-DS-ConsistencyGuid' |
    Where-Object { -not $_.'mS-DS-ConsistencyGuid' } |
    Select-Object Name, DistinguishedName
