# Introduction 
Repository for provisioning the CodeBuildDeploy App platform in Azure

# .ado
This folder contains the Azure DevOps (ADO) pipelines

## Production artifact promotion

The approval on `Prod-Live` gates promotion and deployment. The pipeline copies
the pinned Web, Blogs, and Identity OCI charts and images, including the two
migration images, from `codebuilddeploynonprod` to `codebuilddeployprod`.
It verifies the digests and refuses to replace existing production tags with
different content. Helm deploys those charts directly from production and sets
their `imageRegistry` value to the production registry. Promotion checks that
the charts render the expected application and migration images before copying.
After a chart change, publish and pin the new app builds before deploying to production.

Before enabling a live run, provision the production registry with Platform.Environment
and point the production Azure service connection at the active production subscription.
The production connection identity needs registry lookup access and the
`Container Registry Data Importer and Data Reader` role on both registries in the
same Microsoft Entra tenant. The production AKS image pull secret needs access
to the production registry.

## Istio ingress

Dev, dynamic and Live deployments use the same app release jobs. Each app chart
deploys its own `HTTPRoute`. The shared chart uses `codebuilddeploy-<app_env>` as
the Gateway name and `cbd-<app_env>-ssl-cert` for TLS in the app namespace.
Dev keeps `dev.codebuilddeploy.*`, Live uses `www.codebuilddeploy.*`, and dynamic
deployments use `dyn-<shortsha>.codebuilddeploy.*`.

Run Platform.Environment in the target subscription first to install Istio and
the Gateway API. The platform TLS certificate in Key Vault must cover the target
hostnames. Dynamic deployments can use a wildcard certificate for both domains.
Publish the matching DNS and Nginx Proxy Manager upstreams when an environment is
ready to receive traffic. The gateway chart allowlists the router's static WAN IP.

# terraform
This folder contains the terraform used to provission the acual environments and all its associated infrastructure.

# Key Vault Manual Secrets
## Secrets
```bash
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-dev-jwt-private-key" --value 'Jwt_Private_Key'
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-jwt-private-key" --value 'Jwt_Private_Key'
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
