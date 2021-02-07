

# Azure-deployment-Script-for-linked-templates
Script to deploy Azure Arm templates. Supports linked templates and simple switch to choose paramterfiles.
The script will deploy ARM templates to Azure by first upload all template and parameter files to storageaccount.
The templates are made available securly by securing templates with SAStoken.
The code inclucdes a compleate example of how templates are linked together.

Set all variables for deployed resoruces in template files. The main template is only for linking resources together consider deploying all resoruces as linked templates in order to maintain support for simple switch of deployment environment.


The script supports simple setup in order to support multiple environment. a suffix for parameter files is provided and decides which parameter file are used for the templates.

The convention for templates filenames are TEMPLATENAME.json
The convention for parameters filenames are TEMPLATENAME.PARAMETERS.ENVIRONMENTSUFFIX.json

# Prerequsites

1. Ensure Azure PowerShell is installed (https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
2. Enusre resourcegroup is created in Azure subscription
3. Set variables in scripts, Storage Account and continer will be created if they do not allready exists.

# How to run

1 Run Connect-AzAccount in powershell in order to connect to Azure. Use an account with access to tenant you want to deploy to.
2 If needed select tenant and subscription to deploy to (May be needed if selected account has access to multiple tenants/subscription
3. Run the script by navigating to folder containging script in PowerShell and run ./Deploy-Aztemplate or ./Deploy-Aztemplate.development
if you get an “.ps1 is not digitally signed. The script will not execute on the system.” error run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
In order to allow the script to run.
