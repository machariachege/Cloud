<#
Use this following to Deploy the project
#>
    $test = & ".\AzureAssignment.ps1"  `
        -ServiceName "jpggTest"  `
        -ServiceLocation "Lincoln" `
        -sqlAppDatabaseName "MyData" `
        -StartIPAddress "1.0.0.1" `
        -EndIPAddress "255.255.255.255" `
        -ConfigurationFilePath ".\EnterpiseSite\ServiceConfiguration.Cloud.cscfg" `
        -PackageFilePath ".\EnterpiseSite\WebCorpHolaMundo.Azure.cspkg"
