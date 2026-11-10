# From: https://www.argusit.nl/en/blog/kerberos-rc4-hardening-kdcsvc-events
# Section: Finding them up front with PowerShell
# Read the post first and test in a non-production tenant.

Get-ADDomainController -Filter * | ForEach-Object {
    Invoke-Command -ComputerName $_.HostName -ScriptBlock {
        [pscustomobject]@{
            DC    = $env:COMPUTERNAME
            DDSET = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\KDC' -ErrorAction SilentlyContinue).DefaultDomainSupportedEncTypes
            Phase = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters' -ErrorAction SilentlyContinue).RC4DefaultDisablementPhase
        }
    }
}
