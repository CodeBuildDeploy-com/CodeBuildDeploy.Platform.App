# Introduction 
Repository for provissioning the CodeBuildDeploy App platform in Azure

# azureDevOps
This folder contains the Azure DevOps (ADO) pipelines

# terraform
This folder contains the terraform used to provission the acual environments and all its associated infrastructure.

# Key Vault Manual Secrets
## Secrets
```bash
#https://learn.microsoft.com/en-gb/aspnet/core/security/authentication/social/google-logins
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-dev-google-client-id" --value "Google_Client_Id"
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-dev-google-client-secret" --value "Google_Client_Secret"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-google-client-id" --value "Google_Client_Id"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-google-client-secret" --value "Google_Client_Secret"
#https://learn.microsoft.com/en-gb/aspnet/core/security/authentication/social/microsoft-logins
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-dev-microsoft-client-id" --value "Microsoft_Client_Id"
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-dev-microsoft-client-secret" --value "Microsoft_Client_Secret"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-microsoft-client-id" --value "Microsoft_Client_Id"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-microsoft-client-secret" --value "Microsoft_Client_Secret"
```