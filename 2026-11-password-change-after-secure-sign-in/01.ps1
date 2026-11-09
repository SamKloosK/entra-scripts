Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod"

$body = @{
    "@odata.type"                        = "#microsoft.graph.passwordAuthenticationMethodConfiguration"
    allowPasswordChangeAfterSecureSignIn = $true
}

Invoke-MgGraphRequest -Method PATCH `
    -Uri "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/Password" `
    -Body ($body | ConvertTo-Json) -ContentType "application/json"

# The SDK doesn't have this as a typed property yet, so it shows up under AdditionalProperties
$config = Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
    -AuthenticationMethodConfigurationId "Password"
$config.AdditionalProperties["allowPasswordChangeAfterSecureSignIn"]
