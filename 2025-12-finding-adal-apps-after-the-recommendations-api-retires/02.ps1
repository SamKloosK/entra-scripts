# From: https://argusit.nl/en/blog/finding-adal-apps-after-the-recommendations-api-retires
# Section: Graph PowerShell without Log Analytics
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "AuditLog.Read.All"
# authenticationProcessingDetails is only on the beta signIn resource (Microsoft.Graph.Beta.Reports)
$since = (Get-Date).ToUniversalTime().AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ssZ")

$adal = foreach ($type in 'interactiveUser', 'nonInteractiveUser', 'servicePrincipal') {
    $filter = "createdDateTime ge $since and signInEventTypes/any(t: t eq '$type')"
    Get-MgBetaAuditLogSignIn -Filter $filter -All | ForEach-Object {
        $lib = ($_.AuthenticationProcessingDetails |
            Where-Object Key -eq 'Azure AD App Authentication Library').Value
        if ($lib -match 'ADAL') {
            [pscustomobject]@{
                AppId            = $_.AppId
                AppName          = if ($_.AppDisplayName) { $_.AppDisplayName } else { $_.ServicePrincipalName }
                AppOwnerTenantId = $_.AppOwnerTenantId
                Library          = $lib
                SignInType       = $type
                User             = $_.UserPrincipalName
            }
        }
    }
}

$adal | Group-Object AppId | ForEach-Object {
    [pscustomobject]@{
        AppId            = $_.Name
        AppName          = $_.Group[0].AppName
        AppOwnerTenantId = $_.Group[0].AppOwnerTenantId
        SignIns          = $_.Count
        Users            = @($_.Group.User | Where-Object { $_ } | Sort-Object -Unique).Count
        SignInTypes      = ($_.Group.SignInType | Sort-Object -Unique) -join ', '
        Libraries        = ($_.Group.Library | Sort-Object -Unique) -join '; '
    }
} | Sort-Object SignIns -Descending | Format-Table -AutoSize
