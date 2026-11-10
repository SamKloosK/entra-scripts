# From: https://www.argusit.nl/en/blog/entra-permissions-management-retires-1-october
# Section: What Permissions Management leaves behind in Azure
# Read the post first and test in a non-production tenant.

# Az.Accounts and Az.Resources
Connect-AzAccount
$tenantId = (Get-AzContext).Tenant.Id
$ciem = Get-AzADServicePrincipal -DisplayName 'Cloud Infrastructure Entitlement Management'

$assignments = @()
$customRoles = @()
foreach ($sub in Get-AzSubscription -TenantId $tenantId) {
    Set-AzContext -Subscription $sub.Id | Out-Null
    $assignments += Get-AzRoleAssignment -ObjectId $ciem.Id
    $customRoles += Get-AzRoleDefinition -Custom
}

# Assignments inherited from a management group show up once per subscription
$assignments | Sort-Object RoleAssignmentId -Unique |
    Select-Object RoleDefinitionName, Scope | Format-Table -AutoSize

$customRoles | Sort-Object Id -Unique |
    Select-Object Name, Id, AssignableScopes | Format-Table -AutoSize
