# From: https://argusit.nl/en/blog/kerberos-rc4-hardening-kdcsvc-events
# Section: Finding them up front with PowerShell
# Read the post first and test in a non-production tenant.

$domain  = Get-ADDomain
$aesHint = (Get-ADGroup -Identity "$($domain.DomainSID)-521" -Properties whenCreated).whenCreated

Get-ADUser -LDAPFilter '(servicePrincipalName=*)' -Properties msDS-SupportedEncryptionTypes, pwdLastSet |
    Where-Object SamAccountName -ne 'krbtgt' |
    Select-Object SamAccountName,
        @{ n = 'EncTypes';      e = { $_.'msDS-SupportedEncryptionTypes' } },
        @{ n = 'PwdLastSet';    e = { [datetime]::FromFileTime($_.pwdLastSet) } },
        @{ n = 'BeforeAesHint'; e = { [datetime]::FromFileTime($_.pwdLastSet) -lt $aesHint } } |
    Sort-Object PwdLastSet
