# Set the resource variables
$backend_spn = "tfazinfra"
$backend_rg = "backend-tf-rg"

# Set the Azure DevOps organization and project details
$backend_org = "https://dev.azure.com/tfazlab"
$backend_project = "tfazlab"

# Set the variable group details
$backend_VBGroup = "hawaVB"

# Azure DevOps Connection variables
$backend_AZDOSrvConnName = "azdo-tfaz-conn"

# Azure DevOps variables
$backend_org = "https://dev.azure.com/tfazlab"
$backend_project = "tfazlab"
$backend_AZDOSrvConnName = "azdo-tfaz-conn"
$backend_VBGroup = "hawaVB"
$backend_PipeBuild_Name = "TFaz-Build-Pipe"
$backend_PipeDest_Name = "Tfaz-Destroy-Pipe"
$backend_tfdest_yml = "tfaz_destroy.yml"
$backend_tfaz_build_yml = "tfazbuild.yml"

# Set the SPN password as an environment variable: used by the Azdo Service Connection
$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY=$backend_SPNPass
#$env:AZURE_DEVOPS_EXT_PAT="ww7hj2c25xypj4m6oqc5u5qhzehabll5frjhpu43qus7rql3dfeq"

# Delete Resource Group
Write-Host "Deleting resource group..." -ForegroundColor Yellow
az group delete --name $backend_rg --yes --no-wait
Write-Host "Resource group deleted." -ForegroundColor Green

# Retrieve Application ID
Write-Host "Retrieving Application ID..." -ForegroundColor Yellow
$backend_appId = $(az ad sp list --display-name $backend_spn --query '[0].appId' -o tsv)

# Delete Application
Write-Host "Deleting Azure AD application..." -ForegroundColor Yellow
az ad app delete --id $backend_appId
Write-Host "Azure AD application deleted." -ForegroundColor Green

# Delete Azure DevOps resources
Write-Host "Deleting Azure DevOps resources..." -ForegroundColor Yellow
az devops configure --defaults organization=$backend_org
az devops configure --defaults project=$backend_project

# Delete Service Connection
Write-Host "Retrieving Azure DevOps service connection ID..." -ForegroundColor Yellow
$backend_endPointId = $(az devops service-endpoint list --query "[?name=='$backend_AZDOSrvConnName'].id" -o tsv)
az devops service-endpoint delete --id $backend_endPointId --yes
Write-Host "Azure DevOps service connection deleted." -ForegroundColor Green

# Delete Variable Group
Write-Host "Retrieving Azure DevOps variable group ID..." -ForegroundColor Yellow
$backend_vgId = $(az pipelines variable-group list --query "[?name=='$backend_VBGroup'].id" -o tsv)
az pipelines variable-group delete --id $backend_vgId --yes
Write-Host "Azure DevOps variable group deleted." -ForegroundColor Green

# Delete Pipeline
Write-Host "Retrieving Azure DevOps pipeline ID..." -ForegroundColor Yellow
$backend_pipelineId = $(az pipelines show --org $backend_org --project $backend_project --name $backend_PipeBuild_Name --query 'id' -o tsv)
az pipelines delete --id $backend_pipelineId --org $backend_org --project $backend_project --detect false --yes
Write-Host "Azure DevOps pipeline deleted." -ForegroundColor Green

Write-Host "Retrieving Azure DevOps pipeline ID..." -ForegroundColor Yellow
$backend_pipelineId_dest_id = $(az pipelines show --org $backend_org --project $backend_project --name $backend_PipeDest_Name --query 'id' -o tsv)
az pipelines delete --id $backend_pipelineId_dest_id --org $backend_org --project $backend_project --detect false --yes
Write-Host "Azure DevOps pipeline deleted." -ForegroundColor Green

Write-Host "Resource cleanup completed." -ForegroundColor Green