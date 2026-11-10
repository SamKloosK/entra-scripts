# From: https://www.argusit.nl/en/blog/sspr-registered-methods-only
# Section: Finding them before enforcement
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "AuditLog.Read.All","User.Read.All"

# Registration state for everyone SSPR applies to
$reg = Get-MgReportAuthenticationMethodUserRegistrationDetail -All -Filter "isSsprEnabled eq true"

# Directory contact data for all users, indexed by object ID
$dir = @{}
Get-MgUser -All -Property id,userPrincipalName,mobilePhone,businessPhones,otherMails,onPremisesSyncEnabled |
    ForEach-Object { $dir[$_.Id] = $_ }

$atRisk = foreach ($r in ($reg | Where-Object { -not $_.IsSsprCapable })) {
    $u = $dir[$r.Id]
    if (-not $u) { continue }
    if ($u.MobilePhone -or $u.BusinessPhones.Count -gt 0 -or $u.OtherMails.Count -gt 0) {
        [pscustomobject]@{
            UserPrincipalName = $r.UserPrincipalName
            IsAdmin           = $r.IsAdmin
            Synced            = [bool]$u.OnPremisesSyncEnabled
            MobilePhone       = $u.MobilePhone
            BusinessPhones    = $u.BusinessPhones -join '; '
            OtherMails        = $u.OtherMails -join '; '
            MethodsRegistered = $r.MethodsRegistered -join ', '
        }
    }
}
$atRisk | Export-Csv .\sspr-directory-only.csv -NoTypeInformation
