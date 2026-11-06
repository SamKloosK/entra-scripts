# From: https://argusit.nl/en/blog/conditional-access-register-security-information-windows-hello-platform-sso
# Section: Finding the policies
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Policy.Read.All"

Get-MgIdentityConditionalAccessPolicy -All |
    Where-Object { $_.Conditions.Applications.IncludeUserActions -contains 'urn:user:registersecurityinfo' } |
    Select-Object DisplayName, State,
        @{ n = 'BuiltInControls'; e = { $_.GrantControls.BuiltInControls -join ', ' } },
        @{ n = 'Operator';        e = { $_.GrantControls.Operator } },
        @{ n = 'AuthStrength';    e = { $_.GrantControls.AuthenticationStrength.DisplayName } },
        @{ n = 'InclLocations';   e = { $_.Conditions.Locations.IncludeLocations -join ', ' } },
        @{ n = 'ExclLocations';   e = { $_.Conditions.Locations.ExcludeLocations -join ', ' } },
        @{ n = 'Platforms';       e = { $_.Conditions.Platforms.IncludePlatforms -join ', ' } } |
    Format-Table -AutoSize
