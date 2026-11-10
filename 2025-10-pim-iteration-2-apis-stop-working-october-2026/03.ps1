# From: https://www.argusit.nl/en/blog/pim-iteration-2-apis-stop-working-october-2026
# Section: What the iteration 3 equivalents look like
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "RoleAssignmentSchedule.ReadWrite.Directory"
$me = (Invoke-MgGraphRequest -Method GET -Uri '/v1.0/me?$select=id').id

$params = @{
    Action           = "selfActivate"
    PrincipalId      = $me
    RoleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"   # User Administrator
    DirectoryScopeId = "/"
    Justification    = "CHG0001234"
    ScheduleInfo     = @{
        StartDateTime = (Get-Date).ToUniversalTime()
        Expiration    = @{ Type = "AfterDuration"; Duration = "PT2H" }
    }
}
New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params
