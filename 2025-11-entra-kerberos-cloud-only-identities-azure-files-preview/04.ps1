# From: https://www.argusit.nl/en/blog/entra-kerberos-cloud-only-identities-azure-files-preview
# Section: Checking a session host and the storage account
# Read the post first and test in a non-production tenant.

(Get-AzStorageAccount -ResourceGroupName '<resource-group>' -Name '<account>').AzureFilesIdentityBasedAuth |
    Format-List DirectoryServiceOptions, DefaultSharePermission    # expect AADKERB
