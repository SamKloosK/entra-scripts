Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod"

$uri = "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/Password"

$body = @{
    "@odata.type"                        = "#microsoft.graph.passwordAuthenticationMethodConfiguration"
    allowPasswordChangeAfterSecureSignIn = $true
}

Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body ($body | ConvertTo-Json) -ContentType "application/json"

# Read it back; this only needs the Microsoft.Graph.Authentication module
Invoke-MgGraphRequest -Method GET -Uri $uri | ConvertTo-Json
