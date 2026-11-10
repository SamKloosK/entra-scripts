# From: https://www.argusit.nl/en/blog/entra-connect-sync-first-party-app-conditional-access-sign-in-logs
# Section: Checking version and identity per server
# Read the post first and test in a non-production tenant.

(Get-Item 'C:\Program Files\Microsoft Azure AD Connect\AzureADConnect.exe').VersionInfo.ProductVersion
Get-ADSyncEntraConnectorCredential
Get-ADSyncScheduler | Select-Object StagingModeEnabled, SyncCycleEnabled
