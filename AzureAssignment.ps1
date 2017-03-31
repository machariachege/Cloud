
# Defining the Parameter
Param(
    #Cloud-services Name
    [Parameter(Mandatory = $true)]
    [String]$ServiceName,            
    #Cloud-Service location 
    [Parameter(Mandatory = $true)]
    [String]$ServiceLocation,     
    #Database-application name   
    [Parameter(Mandatory = $true)]
    [String]$sqlAppDatabaseName,     
    #Define First IP Adress
    [Parameter(Mandatory = $true)]            
    [String]$StartIPAddress,   
    #Define Last IP Adress
    [Parameter(Mandatory = $true)]                             
    [String]$EndIPAddress,         
    #Path cscfg
    [Parameter(Mandatory = $true)]                             
    [String]$ConfigurationFilePath,   
    #Path to cspkg
    [Parameter(Mandatory = $true)]                             
    [String]$PackageFilePath            
)
<# Createing AzureCloudServices
.Synopsis
The function Create will create an Azure Cloud Services if the Cloud Service does not exists.
#> 
Function CreateAzureCloudService 
{
 Param(
    #Cloud-services Name
    [Parameter(Mandatory = $true)]
    [String]$MyCloudServiceName,
    #Cloud service Location 
    [Parameter(Mandatory = $true)]
    [String]$MyCloudServiceLocation     
    )

 try
 {
    $CloudService = Get-AzureService -ServiceName $MyCloudServiceName
    Write-Verbose ("cloud service {0} in location {1} exist!" -f $MyCloudServiceName, $MyCloudServiceLocation)
 }
 catch
 { 
   #Create
   Write-Verbose ("[Start] creating cloud service {0} in location {1}" -f $MyCloudServiceName, $MyCloudServiceLocation)
   New-AzureService -ServiceName $MyCloudServiceName -Location $MyCloudServiceLocation
   Write-Verbose ("[Finish] creating cloud service {0} in location {1}" -f $MyCloudServiceName, $MyCloudServiceLocation)
 }
}
<# CreateAzureStorage
.Synopsis
The function will create an Azure Cloud Storage Account none exists with the defined name.

#>
Function CreateAzureStorage
{
Param (
    #Storage-Account Name
    [Parameter(Mandatory = $true)]
    [String]$MyAzzureStorageAccount,
    #Storage-Account Location 
    [Parameter(Mandatory = $true)]
    [String]$MyAzzureStorageLocation 
)
    try
    {
        $myStorageAccount= Get-AzureStorageAccount -StorageAccountName $MyAzzureStorageAccount
        Write-Verbose ("Storage account {0} in location {1} exist" -f $MyAzzureStorageAccount, $MyAzzureStorageLocation)
    }
    catch
    {
        # Create a new storage account
        Write-Verbose ("[Start] creating storage account {0} in location {1}" -f $MyAzzureStorageAccount, $MyAzzureStorageLocation)
        New-AzureStorageAccount -StorageAccountName $MyAzzureStorageAccount -Location $MyAzzureStorageLocation -Verbose
        Write-Verbose ("[Finish] creating storage account {0} in location {1}" -f $MyAzzureStorageAccount, $MyAzzureStorageLocation)
    }

    # Get the access key of the storage account
    $key = Get-AzureStorageKey -StorageAccountName $MyAzzureStorageAccount

    # Generate the connection string of the storage account
    $connectionString ="BlobEndpoint=http://{0}.blob.core.windows.net/;" -f $MyAzzureStorageAccount
    $connectionString =$connectionString + "QueueEndpoint=http://{0}.queue.core.windows.net/;" -f $MyAzzureStorageAccount
    $connectionString =$connectionString + "TableEndpoint=http://{0}.table.core.windows.net/;" -f $MyAzzureStorageAccount
    $connectionString =$connectionString + "AccountName={0};AccountKey={1}" -f $MyAzzureStorageAccount, $key.Primary

    Return @{ConnectionString = $connectionString}
}
<# Update-Cscfg
.Synopsis
    The function will update the Cloud Services config file with the Azure SQL and Storage account information
#>
Function Update-Cscfg 
{
Param (
    #Path to configuration file (*.cscfg)
    [Parameter(Mandatory = $true)]
    [String]$MyConfigFilePath,
    #Azure SQL connection string 
    [Parameter(Mandatory = $true)]
    [String]$MySqlConnStr ,
    #Storage Account connection String 
    [Parameter(Mandatory = $true)]
    [String]$MyAzzureStorageConnStr 
)
    # Get content of the project source cscfg file
    [Xml]$cscfgXml = Get-Content $MyConfigFilePath
    Foreach ($role in $cscfgXml.ServiceConfiguration.Role)
    {
        Foreach ($setting in $role.ConfigurationSettings.Setting)
        {
            Switch ($setting.name)
            {
                "dbApplication" {$setting.value =$MySqlConnStr} #AppDatabase
                "Storage" {$setting.value = $MyAzzureStorageConnStr}  #Storage
            }
        }
    }
    #Save the change
    $file = "{0}\EnterpiseSite\ServiceConfiguration.Ready.cscfg" -f $ScriptPath
    $cscfgXml.InnerXml | Out-File -Encoding utf8 $file
    Return $file
}
<# DeploymentPackage
    The function deploys the service  package with its configuration to the Cloud Services          
#>
Function DeploymentPackage 
{
Param(
    #Cloud-Services name
    [Parameter(Mandatory = $true)]
    [String]$MyCloudServiceName,
    #Path to the config file
    [Parameter(Mandatory = $true)]
    [String]$MyConfigFilePath,
    #Path to the package file
    [Parameter(Mandatory = $true)]
    [String]$MyPackageFilePath
)
    Try
    {
        Get-AzureDeployment -ServiceName $MyCloudServiceName
        Write-Verbose ("[Start] Deploy Service {0}  exist, Will update" -f $MyCloudServiceName)
        Set-AzureDeployment `
            -ServiceName $MyCloudServiceName `
            -Slot Production `
            -Configuration $MyConfigFilePath `
            -Package $MyPackageFilePath `
            -Mode Simultaneous -Upgrade
        Write-Verbose ("[finish] Deploy Service {0}  exist, Will update" -f $MyCloudServiceName)
    }
    Catch
    {
        Write-Verbose ("[Start] Deploy Service {0} don't exist, Will create" -f $MyCloudServiceName)
        New-AzureDeployment -ServiceName $MyCloudServiceName -Slot Production -Configuration $MyConfigFilePath -Package $MyPackageFilePath
        Write-Verbose ("[Finish] Deploy Service {0} don't exist, Will create" -f $MyCloudServiceName)
    }
    
}
<# WaitRoleInstancesReady
    it waits for all role instances to be ready
#>
function WaitRoleInstancesReady 
{
Param(
    #Cloud-Services name
    [Parameter(Mandatory = $true)]
    [String]$MyCloudServiceName
)
    Write-Verbose ("[Start] Waiting for Instance Ready")
    do
    {
        $MyDeploy = Get-AzureDeployment -ServiceName $MyCloudServiceName  
        foreach ($Instancia in $MyDeploy.RoleInstanceList)
        {
            $switch=$true
            Write-Verbose ("Instance {0} is in state {1}" -f $Instancia.InstanceName, $Instancia.InstanceStatus )
            if ($Instancia.InstanceStatus -ne "ReadyRole")
            {
                $switch=$false
            }
        }
        if (-Not($switch))
        {
            Write-Verbose ("Waiting Azure Deploy running, it status is {0}" -f $MyDeploy.Status)
            Start-Sleep -s 10
        }
        else
        {
            Write-Verbose ("[Finish] Waiting for Instance Ready")
        }
    }
    until ($switch)
}


<# Detects-IPAddress
    Gets the IP Range that needs to be whitelisted for the SQL Azure
#>
Function Detects-IPAddress
{
    $ipregex = "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    $text = Invoke-RestMethod 'http://www.whatismyip.com/api/wimi.php'
    $result = $null

    If($text -match $ipregex)
    {
        $ipaddress = $matches[0]
        $ipparts = $ipaddress.Split('.')
        $ipparts[3] = 0
        $startip = [string]::Join('.',$ipparts)
        $ipparts[3] = 255
        $endip = [string]::Join('.',$ipparts)

        $result = @{StartIPAddress = $startip; EndIPAddress = $endip}
    }

    Return $result
}
<# Gets-SQLAzureDatabaseConnectionString

    Generates the connection string for a particular SQL Azure database

#>
Function Gets-SQLAzureDatabaseConnectionString
{
    Param(
        #Database-Server Name
        [String]$DatabaseServerName,
        #Database-name
        [String]$DatabaseName,
        #Database Use Name
        [String]$SqlDatabaseUserName ,
        #Database User Password
        [String]$Password
    )

    Return "Server=tcp:{0}.database.windows.net,1433;Database={1};User ID={2}@{0};Password={3};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;" -f
        $DatabaseServerName, $DatabaseName, $SqlDatabaseUserName , $Password
}
<# CreateAzureSqlDatabase
    This script will create an Azure SQl Server as well as a Database
#>
Function CreateAzureSqlDB
{
Param(
    #Application database-name
    [Parameter(Mandatory = $true)]
    [String]$AppDatabaseName,   
    #Database-server firewall rule-name
    [Parameter(Mandatory = $true)]
    [String]$FirewallRuleName ,            
    #First IP Adress of the range of IP's with access to the database.
    [Parameter(Mandatory = $true)]
    [String]$StartIPAddress,               
    #Last IP Adress of the Range of IP's with access to the database
    [Parameter(Mandatory = $true)]
    [String]$EndIPAddress,       
    #Database Server-Location          
    [Parameter(Mandatory = $true)]
    [String]$Location                      
)

# Detects the IP range for the SQL Azure whitelisting when the IP range has not been specified
If (-not ($StartIPAddress -and $EndIPAddress))
{
    $ipRange = Detects-IPAddress
    $StartIPAddress = $ipRange.StartIPAddress
    $EndIPAddress = $ipRange.EndIPAddress
}

# Prompts for Credential
$credential = Get-Credential
# Creates Server
Write-Verbose ("[Start] creating SQL Azure database server in location {0} with username {1} and password {2}" -f $Location, $credential.UserName , $credential.GetNetworkCredential().Password)
$databaseServer = New-AzureSqlDatabaseServer -AdministratorLogin $credential.UserName  -AdministratorLoginPassword $credential.GetNetworkCredential().Password -Location $Location
Write-Verbose ("[Finish] creating SQL Azure database server {3} in location {0} with username {1} and password {2}" -f $Location, $credential.UserName , $credential.GetNetworkCredential().Password, $databaseServer.ServerName)

# Creates the SQL Azure DB server firewall rule
Write-Verbose ("[Start] creating firewall rule {0} in database server {1} for IP addresses {2} - {3}" -f $RuleName, $databaseServer.ServerName, $StartIPAddress, $EndIPAddress)
New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName $FirewallRuleName -StartIpAddress $StartIPAddress -EndIpAddress $EndIPAddress -Verbose
New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName "AllowAllAzureIP" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0" -Verbose
Write-Verbose ("[Finish] creating firewall rule {0} in database server {1} for IP addresses {2} - {3}" -f $FirewallRuleName, $databaseServer.ServerName, $StartIPAddress, $EndIPAddress)

# Creates a DB context which include the server-name and credentials
$context = New-AzureSqlDatabaseServerContext -ServerName $databaseServer.ServerName -Credential $credential 

# Uses the DB context to create an app DB
Write-Verbose ("[Start] creating database {0} in database server {1}" -f $AppDatabaseName, $databaseServer.ServerName)
New-AzureSqlDatabase -DatabaseName $AppDatabaseName -Context $context -Verbose
Write-Verbose ("[Finish] creating database {0} in database server {1}" -f $AppDatabaseName, $databaseServer.ServerName)

# Generates the Connection-String
[string] $appDatabaseConnectionString = Get-SQLAzureDatabaseConnectionString -DatabaseServerName $databaseServer.ServerName -DatabaseName $AppDatabaseName -SqlDatabaseUserName $credential.UserName  -Password $credential.GetNetworkCredential().Password

# Return Database connection-string
   Return @{ConnectionString = $appDatabaseConnectionString;}
}



# Same variables to be used in the Scripts
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"
# Gets the directory of the current scripts
$ScriptPath = Split-Path -parent $PSCommandPath
# Marks the start-time of the script executions
$StartTime = Get-Date
# Defines the names of storage-accounts, SQL Azure DB and SQL Azure DB servers firewall rules
$ServiceName = $ServiceName.ToLower()
$StorageAccountName = "{0}storage" -f $ServiceName
$SqlDatabaseServerFirewallRuleName = "{0}rule" -f $ServiceName

# Creates the new Azure cloud service.
# creating the Windows-Azure cloud-service environments
Write-Verbose ("[Start] Validating  Windows Azure cloud service environment {0}" -f $ServiceName)
CreateAzureCloudService  $ServiceName $ServiceLocation

# Creating a new storage-account
$Storage = CreateAzureStorage -MyAzzureStorageAccount $StorageAccountName -MyAzzureStorageLocation $ServiceLocation

# Creating a new SQL Azure DB server and App DB
[string] $SqlConn = CreateAzureSqlDB `
        -AppDatabaseName $sqlAppDatabaseName `
        -StartIPAddress $StartIPAddress `
        -EndIPAddress $EndIPAddress -FirewallRuleName $SqlDatabaseServerFirewallRuleName `
        -Location $ServiceLocation

Write-Verbose ("[Finish] creating Windows Azure cloud service environment {0}" -f $ServiceName)

# Upgrading the config
$NewcscfgFilePath = Update-Cscfg  `
            -MyConfigFilePath $ConfigurationFilePath  `
            -MySqlConnStr $SqlConn `
            -MyAzzureStorageConnStr $Storage.ConnectionString
Write-Verbose ("New Config File {0}" -f $NewcscfgFilePath)

# Deploying the Package
DeployPackage -MyCloudServiceName $ServiceName -MyConfigFilePath $NewcscfgFilePath -MyPackageFilePath $PackageFilePath

# Deleting temporal config File
Remove-Item $NewcscfgFilePath

# Waiting Role isntances to be Ready
WaitRoleInstanceReady $ServiceName


# Marking the finish-time of the script's executions

$finishTime = Get-Date

Write-Host ("Total time used (seconds): {0}" -f ($finishTime - $StartTime).TotalSeconds)

# Launching the Cloud
Start-Process -FilePath ("http://{0}.cloudapp.net" -f $ServiceName)
