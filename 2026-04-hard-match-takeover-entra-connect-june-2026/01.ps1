# From: https://www.argusit.nl/en/blog/hard-match-takeover-entra-connect-june-2026
# Section: Finding admin accounts with an anchor
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "RoleManagement.Read.Directory", "Directory.Read.All"

$roleNames = @{}
Get-MgRoleManagementDirectoryRoleDefinition -All |
    ForEach-Object { $roleNames[$_.Id] = $_.DisplayName }

$grants = @(
    Get-MgRoleManagementDirectoryRoleAssignment -All |
        Select-Object PrincipalId, RoleDefinitionId, @{ n = 'Kind'; e = { 'Active' } }
    Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All |
        Select-Object PrincipalId, RoleDefinitionId, @{ n = 'Kind'; e = { 'Eligible' } }
)

# Role-assignable groups: report their members
$expanded = foreach ($g in $grants) {
    $obj = Get-MgDirectoryObject -DirectoryObjectId $g.PrincipalId
    if ($obj.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.group') {
        Get-MgGroupMember -GroupId $g.PrincipalId -All | ForEach-Object {
            [pscustomobject]@{ PrincipalId = $_.Id; RoleDefinitionId = $g.RoleDefinitionId; Kind = "$($g.Kind) via group" }
        }
    }
    else { $g }
}

$expanded | Group-Object PrincipalId | ForEach-Object {
    $u = Get-MgUser -UserId $_.Name -Property Id, UserPrincipalName, OnPremisesImmutableId, OnPremisesSyncEnabled -ErrorAction SilentlyContinue
    if ($u.OnPremisesImmutableId) {
        [pscustomobject]@{
            UserPrincipalName     = $u.UserPrincipalName
            OnPremisesSyncEnabled = $u.OnPremisesSyncEnabled
            OnPremisesImmutableId = $u.OnPremisesImmutableId
            Roles = ($_.Group | ForEach-Object { "$($roleNames[$_.RoleDefinitionId]) ($($_.Kind))" } | Sort-Object -Unique) -join '; '
        }
    }
} | Format-Table -AutoSize
