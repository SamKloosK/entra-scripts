# From: https://www.argusit.nl/en/blog/passkey-profile-migration-existing-fido2-policy
# Section: Reading your current configuration
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "UserAuthMethod-Passkey.Read.All"
$upn = "admin@contoso.com"
(Invoke-MgGraphRequest -Method GET -OutputType PSObject -Uri "https://graph.microsoft.com/beta/users/$upn/authentication/fido2Methods").value |
    Select-Object displayName, model, aaGuid, attestationLevel, passkeyType
