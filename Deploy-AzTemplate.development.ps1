

#In order to use script

# 1. Set variables in script. The script needs an exsisting resoruce group, ensure it it created before running the skriåt
# Storage Account and continer will be created if they do not allready exists. They are used to store templates during deployment.
# 2.  Ensure Azure PowerShell is installed (https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
# 3. Run Connect-AzAccount in powershell in order to connect to Azure. Use an account with access to tenant you want to deploy to.
# 4. If needed select tenant and subscription to deploy to (May be needed if selected account has access to multiple tenants/subscriptions)

# 5. Run the script by navigating to folder containging script in PowerShell and run ./Deploy-Aztemplate.development

$resourceGroupName = "axelresourcegroup"  
$storageAccName = "staging39230xx"  
$location = "northeurope"
$storageContainerName = "templates"
$maintemplate = "azuredeploy2.json"
#Suffix to use for parameter files the parameter file suffix used when deploying linked resoruces
$environmentparamtersuffix = ".development"



## Check if storage account exists  
if (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor Magenta $storageAccName "- storage account already exists."     
}  
else {  
    Write-Host -ForegroundColor Magenta $storageAccName "- storage account does not exist."  
    Write-Host -ForegroundColor Green "Creating the storage account - " $storageAccName   

    ## Create a new Azure Storage Account  
    New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName -Location $location -SkuName Standard_LRS   
}  

  
Set-AzCurrentStorageAccount `
    -ResourceGroupName axelresourcegroup `
    -Name $storageAccName


## Check if container account exists  
if (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor Magenta $storageContainerName "- container already exists."     
}  
else {  
    Write-Host -ForegroundColor Magenta $storageContainerName "- storage account does not exist."  
    Write-Host -ForegroundColor Green "Creating the container account - " $storageContainerName   
  
    ## Create a new Azure Storage Account  
    New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName -Location $location -SkuName Standard_LRS   
}  

# Set storage account after ensured it exists or it has been created
Set-AzCurrentStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccName

# Check if Container exists, if not it is created.
if (Get-AzStorageContainer -Name $storageContainerName -Context $ctx -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor Magenta $storageContainerName "- container already exists."  
}  
else {  
    Write-Host -ForegroundColor Magenta $storageContainerName "- container does not exist."   
    ## Create a new Azure Storage Account  
    New-AzStorageContainer -Name $storageContainerName -Context $ctx -Permission Container  
}       

# Gets URI/URL of containers. This is the container to which all template files will be uploaded refred to as artifactlocation
$storageContainer = Get-AzStorageContainer -Name $storageContainerName
$artifactLocation = $storageContainer.CloudBlobContainer.Uri.AbsoluteUri

# Gets all .json (arm-templates) files relative paths in current folder. Preserves folder structure once the templates are uploaded in order to allow relative linking.
$files = (Get-ChildItem . -recurse -Filter *.json ).FullName | Resolve-Path -Relative

# Upload each template file to blob. Folder structure is preserved.
foreach($file in $files){
   
    Set-AzStorageBlobContent -Context $context -File "$file" -Container $storageContainerName -Blob "$file" -Force
}


# get the URI with the SAS token
# This token allows read access to the continer for 30 minutes. This ensures the deployment script can read the template files
$sasToken = New-AzStorageContainerSASToken `
  -Container templates `
  -Permission r `
  -ExpiryTime (Get-Date).AddMinutes(30.0)

# Convert token to secure string in order to pass to template.
$securetoken = ConvertTo-SecureString -AsPlainText -Force ( $sasToken)


Write-Host -ForegroundColor Green "Deployment Started" 
# provide URI with SAS token during deployment
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $artifactLocation"/"$maintemplate$sasToken -containerSasToken $securetoken -artifactLocation $artifactLocation -parameterFileSuffix $environmentparamtersuffix

Write-Host -ForegroundColor Green "Deployment Done" 