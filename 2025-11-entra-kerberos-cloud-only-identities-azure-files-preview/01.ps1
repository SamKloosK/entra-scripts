# From: https://www.argusit.nl/en/blog/entra-kerberos-cloud-only-identities-azure-files-preview
# Section: The mandatory manifest tag and the group SID limit
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Report: all storage account app registrations and whether they carry the tag
Get-MgApplication -All -Filter "startswith(displayName,'[Storage Account]')" -Property Id, DisplayName, Tags |
    Select-Object DisplayName, @{ n = 'CloudGroupSids'; e = { $_.Tags -contains 'kdc_enable_cloud_group_sids' } }

# Append the tag for one storage account without dropping existing tags
$name = '[Storage Account] <account>.file.core.windows.net'
$app  = Get-MgApplication -Filter "displayName eq '$name'" -Property Id, Tags
if ($app.Tags -notcontains 'kdc_enable_cloud_group_sids') {
    $tags = @($app.Tags | Where-Object { $_ }) + 'kdc_enable_cloud_group_sids'
    Update-MgApplication -ApplicationId $app.Id -Tags $tags
}
