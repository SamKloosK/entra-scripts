# From: https://www.argusit.nl/en/blog/entra-connect-sync-first-party-app-conditional-access-sign-in-logs
# Section: Who can act as your sync
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Application.Read.All", "RoleManagement.Read.Directory"

$syncSp = Get-MgServicePrincipal -Filter "appId eq '6bf85cfa-ac8a-4be5-b5de-425a0d0dc016'"
$syncSp | Select-Object DisplayName, Id, AccountEnabled, AppRoleAssignmentRequired

$roleNames = @{}
$syncSp.AppRoles | ForEach-Object { $roleNames[$_.Id] = $_.Value }

# Principals holding an app role on the sync resource (the Connect applications)
Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $syncSp.Id -All |
    Where-Object PrincipalType -eq 'ServicePrincipal' |
    ForEach-Object {
        $sp  = Get-MgServicePrincipal -ServicePrincipalId $_.PrincipalId
        $app = Get-MgApplication -Filter "appId eq '$($sp.AppId)'"
        [pscustomobject]@{
            Principal     = $_.PrincipalDisplayName
            AppRole       = $roleNames[$_.AppRoleId]
            AssignedOn    = $_.CreatedDateTime
            AppCerts      = @($app.KeyCredentials).Count
            AppSecrets    = @($app.PasswordCredentials).Count
            SpCredentials = @($sp.KeyCredentials).Count + @($sp.PasswordCredentials).Count
            Owners        = (Get-MgApplicationOwner -ApplicationId $app.Id |
                                ForEach-Object { $_.AdditionalProperties.userPrincipalName }) -join '; '
        }
    } | Format-Table -AutoSize

# Legacy connector accounts (Directory Synchronization Accounts role)
$dsaRole = Get-MgDirectoryRole | Where-Object RoleTemplateId -eq 'd29b2b05-8046-44ba-8758-1e26182fcf32'
Get-MgDirectoryRoleMember -DirectoryRoleId $dsaRole.Id |
    Select-Object Id, @{ n = 'UserPrincipalName'; e = { $_.AdditionalProperties.userPrincipalName } }
