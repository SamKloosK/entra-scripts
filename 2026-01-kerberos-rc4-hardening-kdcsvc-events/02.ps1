# From: https://argusit.nl/en/blog/kerberos-rc4-hardening-kdcsvc-events
# Section: Finding them up front with PowerShell
# Read the post first and test in a non-production tenant.

Get-ADDomainController -Filter * | ForEach-Object {
    Get-WinEvent -ComputerName $_.HostName -FilterHashtable @{ LogName = 'System'; Id = 201..209 } -ErrorAction SilentlyContinue |
        Where-Object ProviderName -match 'Kdc|Key-Distribution'
} | ForEach-Object {
    [pscustomobject]@{
        Id      = $_.Id
        Service = if ($_.Message -match 'Service Name:\s+(\S+)')   { $Matches[1] }
        Client  = if ($_.Message -match 'Client Address:\s+(\S+)') { $Matches[1] }
    }
} | Group-Object Id, Service, Client | Sort-Object Count -Descending | Select-Object Count, Name
