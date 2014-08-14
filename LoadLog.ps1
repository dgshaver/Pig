$BlobStorageAccount = '<Storage Account>';
$DefaultStorageContainer = '<Default Storage Container for HDI Cluster>';
$SubscriptionId = Get-AzureSubscription | ForEach-Object { $_.SubscriptionId };
$SubscriptionName = Get-AzureSubscription | ForEach-Object { $_.SubscriptionName };
$ClusterDnsName = '<HDI Cluster DNS Name>';
$ScriptsFolder = 'scripts/pig'
$ScriptName = 'LoadLog.pig'
$ParamFile = 'ParamFile.txt';
$PrimaryStorageKey = (Get-AzureStorageKey -StorageAccountName $BlobStorageAccount).Primary;
$HdiClusterAdmin = '<Cluster UserName>'
$HdiAdminPassword = ConvertTo-SecureString "<Cluster Password>" -AsPlainText -Force
$HdiClusterCredentials = New-Object System.Management.Automation.PSCredential ($HdiClusterAdmin, $HdiAdminPassword)


# Hdi Cluster that will run pig script
Get-AzureHDInsightCluster -Name $ClusterDnsName -Subscription ((Get-AzureSubscription).SubscriptionId) 
# Get storage context
$AzureStorageContext = New-AzureStorageContext -StorageAccountName $BlobStorageAccount -StorageAccountKey $PrimaryStorageKey
# Copy pig script and parameter file up to Azure storage where they can be accessed by the Templeton server
Set-AzureStorageBlobContent -File C:\src\Hadoop\Pig\LoadLog.pig -BlobType Block -Container $DefaultStorageContainer -Context $AzureStorageContext -Blob http://$BlobStorageAccount.blob.core.windows.net/$DefaultStorageContainer/$ScriptsFolder/$ScriptName 
Set-AzureStorageBlobContent -File C:\src\Hadoop\Pig\ParamFile.txt -BlobType Block -Container $DefaultStorageContainer -Context $AzureStorageContext -Blob http://$BlobStorageAccount.blob.core.windows.net/$DefaultStorageContainer/$ScriptsFolder/$ParamFile  
$InputFile = 'iis.log';
$Month = '07';
$Day = '27';

# Files required by the job (Pig script and parameter file)
$param_file = "wasb://$DefaultStorageContainer@$BlobStorageAccount.blob.core.windows.net/$ScriptsFolder/$ParamFile"
$pigScript = "wasb://$DefaultStorageContainer@$BlobStorageAccount.blob.core.windows.net/$ScriptsFolder/$ScriptName"

$pigParams =  "-verbose","-warning","-stop_on_failure"
$pigParams += "-param","INPUTFILE=$InputFile"
$pigParams += "-param","MONTH=$Month"
$pigParams += "-param","DAY=$Day"
$pigParams += "-param_file","$param_file"
# Create pig job definition
$pigJobDefinition = New-AzureHDInsightPigJobDefinition -File $PigScript -Arguments $PigParams -Debug
# Start the job
$pigJob = Start-AzureHDInsightJob -Subscription $subscriptionName -Cluster $ClusterDnsName -JobDefinition $pigJobDefinition -Debug
 
Get-AzureHDInsightJob -Subscription $subscriptionName -Cluster $ClusterDnsName -JobId $pigJob.JobId