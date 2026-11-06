# From: https://argusit.nl/en/blog/entra-kerberos-cloud-only-identities-azure-files-preview
# Section: The mandatory manifest tag and the group SID limit
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "User.Read.All", "GroupMember.Read.All"
$upn = '<user@domain>'
Get-MgUser -UserId $upn -Property UserPrincipalName, SecurityIdentifier | Select-Object UserPrincipalName, SecurityIdentifier
(Get-MgUserTransitiveMemberOfAsGroup -UserId $upn -All -Property Id, SecurityEnabled |
    Where-Object SecurityEnabled).Count
