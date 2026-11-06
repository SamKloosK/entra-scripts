# From: https://argusit.nl/en/blog/pim-iteration-2-apis-stop-working-october-2026
# Section: Permission grants and sign-in logs as a second net
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All"

$graphSp = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
$pattern = '^PrivilegedAccess\.(Read|ReadWrite)\.(AzureAD|AzureADGroup|AzureResources)$'
$roleNames = @{}
$graphSp.AppRoles | ForEach-Object { $roleNames[$_.Id] = $_.Value }

$appHits = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $graphSp.Id -All |
    Where-Object { $roleNames[$_.AppRoleId] -match $pattern } |
    Select-Object @{ n = 'Client'; e = { $_.PrincipalDisplayName } }, PrincipalId,
        @{ n = 'Type'; e = { 'Application' } }, @{ n = 'Permission'; e = { $roleNames[$_.AppRoleId] } }

$delegatedHits = Get-MgOauth2PermissionGrant -Filter "resourceId eq '$($graphSp.Id)'" -All |
    ForEach-Object {
        $grant = $_
        $grant.Scope -split ' ' | Where-Object { $_ -match $pattern } | ForEach-Object {
            [pscustomobject]@{
                Client      = (Get-MgServicePrincipal -ServicePrincipalId $grant.ClientId).DisplayName
                PrincipalId = $grant.ClientId
                Type        = "Delegated ($($grant.ConsentType))"
                Permission  = $_
            }
        }
    } | Sort-Object PrincipalId, Type, Permission -Unique

@($appHits) + @($delegatedHits) | Sort-Object Client | Format-Table -AutoSize
