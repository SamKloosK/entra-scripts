# From: https://www.argusit.nl/en/blog/finding-adal-apps-after-the-recommendations-api-retires
# Section: Graph PowerShell without Log Analytics
# Read the post first and test in a non-production tenant.

Connect-MgGraph -Scopes "DirectoryRecommendations.Read.All"
$tenantId = (Get-MgContext).TenantId

Get-MgBetaDirectoryRecommendationImpactedResource -RecommendationId "${tenantId}_adalToMsalMigration" -All |
    Select-Object DisplayName, SubjectId, Status, AddedDateTime,
        @{ n = 'Library'; e = { ($_.AdditionalDetails | Where-Object Key -eq 'Library').Value } } |
    Export-Csv -Path .\adal-recommendation-export.csv -NoTypeInformation
