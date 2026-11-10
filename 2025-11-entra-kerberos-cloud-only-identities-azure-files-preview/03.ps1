# From: https://www.argusit.nl/en/blog/entra-kerberos-cloud-only-identities-azure-files-preview
# Section: Checking a session host and the storage account
# Read the post first and test in a non-production tenant.

dsregcmd /status                                      # SSO State: AzureAdPrt YES, CloudTgt YES
klist cloud_debug                                     # "Cloud Kerberos enabled by policy" should be 1
klist get "cifs/<account>.file.core.windows.net"      # service ticket from KERBEROS.MICROSOFTONLINE.COM
