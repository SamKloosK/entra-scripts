# From: https://argusit.nl/en/blog/entra-connect-sync-to-cloud-sync-what-stays-behind
# Section: Running the migration side by side
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes 'User.Read.All'
$ou = 'OU=Pilot,DC=contoso,DC=com'
$synced = Get-MgUser -All -Filter 'onPremisesSyncEnabled eq true' `
    -Property id,userPrincipalName,onPremisesDistinguishedName
($synced | Where-Object { $_.OnPremisesDistinguishedName -like "*,$ou" }).Count
