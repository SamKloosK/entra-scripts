# From: https://www.argusit.nl/en/blog/passkey-profile-migration-existing-fido2-policy
# Section: Reading your current configuration
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Policy.Read.AuthenticationMethod"

$fido2 = Invoke-MgGraphRequest -Method GET -OutputType PSObject -Uri "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2"
$fido2 | Select-Object state, isSelfServiceRegistrationAllowed, isAttestationEnforced
$fido2.keyRestrictions
$fido2.includeTargets
$fido2.passkeyProfiles

$policy = Invoke-MgGraphRequest -Method GET -OutputType PSObject -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy"
$policy.registrationEnforcement.authenticationMethodsRegistrationCampaign
