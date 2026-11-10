# From: https://www.argusit.nl/en/blog/external-mfa-in-entra-id-and-custom-controls
# Section: Running both during the migration
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Policy.Read.All","UserAuthMethod-External.ReadWrite.All"

# Conditional Access policies that require a custom control
Get-MgIdentityConditionalAccessPolicy -All |
    Where-Object { $_.GrantControls.CustomAuthenticationFactors } |
    Select-Object DisplayName, State,
        @{N='CustomControls'; E={ $_.GrantControls.CustomAuthenticationFactors -join ', ' }},
        @{N='BuiltIn';        E={ $_.GrantControls.BuiltInControls -join ', ' }},
        @{N='Operator';       E={ $_.GrantControls.Operator }}

# External MFA methods in the authentication methods policy
$amp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy"
$amp.authenticationMethodConfigurations |
    Where-Object { $_.'@odata.type' -eq '#microsoft.graph.externalAuthenticationMethodConfiguration' } |
    ForEach-Object { [pscustomobject]@{ Id = $_.id; Name = $_.displayName; State = $_.state; DiscoveryUrl = $_.openIdConnectSetting.discoveryUrl } }

# Register External MFA for a user on their behalf
# (the signed-in admin needs Authentication Administrator or Privileged Authentication Administrator)
$body = @{ configurationId = "<Id from the previous output>"; displayName = "<method name>" } | ConvertTo-Json
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users/<user id>/authentication/externalAuthenticationMethods" -Body $body -ContentType "application/json"
