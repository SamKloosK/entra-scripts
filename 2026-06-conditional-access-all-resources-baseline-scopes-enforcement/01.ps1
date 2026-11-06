# From: https://argusit.nl/en/blog/conditional-access-all-resources-baseline-scopes-enforcement
# Section: Finding the affected policies and sign-ins
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Policy.Read.All"

Get-MgIdentityConditionalAccessPolicy -All |
    Where-Object {
        $_.Conditions.Applications.IncludeApplications -contains "All" -and
        $_.Conditions.Applications.ExcludeApplications.Count -gt 0
    } |
    Select-Object DisplayName, State,
        @{ n = "ExcludedApps"; e = { $_.Conditions.Applications.ExcludeApplications -join ", " } },
        @{ n = "Grant";        e = { $_.GrantControls.BuiltInControls -join ", " } }
