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

CI, dynamic and Live deployments use the same app release jobs. Each app chart
deploys its own `HTTPRoute`. The shared chart uses `codebuilddeploy-<app_env>` as
the Gateway name and `cbd-<app_env>-ssl-cert` for TLS in the app namespace.
CI uses `ci.codebuilddeploy.*`, Live uses `www.codebuilddeploy.*`, and dynamic
deployments use `dyn-<shortsha>.codebuilddeploy.*`.

Run Platform.Environment in the target subscription first to install Istio and
the Gateway API. The TLS certificate in Key Vault must cover the target
hostnames. CI reads its own certificate and key pair. Dynamic and Live deployments
read their respective platform pair.
Publish the matching DNS and Nginx Proxy Manager upstreams when an environment is
ready to receive traffic. The chart creates a private Azure Load Balancer frontend
that only accepts traffic from the platform's WireGuard VM private address. The
router needs a WireGuard route to that frontend before publishing the upstream.
The App Terraform `aks_cluster_configure` module manages the gateway Helm release.
It reads the WireGuard NIC and AKS subnet from Azure. CI uses the ninth IP from
the end of the non-production AKS subnet (`10.0.4.119` in the current layout),
so it can coexist with Dev at `10.0.4.120`. Live uses the eighth IP from the end
of its subnet. Dynamic deployments use an Azure-assigned IP.
For an existing environment, Terraform upgrades the same-named release in place
on its first apply. A new environment installs the release after the namespace
and TLS secret are available. The App deployment jobs release Blogs, Identity and
Web, then verify that Istio has accepted their routes.
Use the private Service's load balancer IP as the Nginx Proxy Manager upstream.
The generated Istio Service uses ClusterIP.

## Moving the stable non-production app from Dev to CI

- The stable pipeline target is `NonProd-CI`, with `ci.tfvars`, `nonprod-ci.tfstate`
  and namespace `cbd-nonprod-ci`. A manual run with **Deploy to CI** on `main` or a
  release branch targets CI. Other branches retain the dynamic environment behavior.
  Create and authorize `NonProd-CI` in Azure DevOps before the first run. The
  existing `CodeBuildDeploy-NonProd-Dev` variable group is still shared with dynamic runs.
- CI needs the `cbd-nonprod-ci-tls-cert` and `cbd-nonprod-ci-tls-key` secrets in
  `cbd-enterprise-kv`. Use a matching certificate and key for both
  `ci.codebuilddeploy.com` and `ci.codebuilddeploy.co.uk`. Populate the CI JWT and
  OAuth secrets listed below. Register the CI callback URLs for Microsoft and Google
  (`/Identity/signin-microsoft` and `/Identity/signin-google`) before testing sign-in.
- CI provisions a separate SQL database and storage account. If existing Dev data
  is needed in CI, copy the Dev database to `cbd-nonprod-ci-sql-database` and import
  the copy into CI state at `module.cbd_app_sql_database.azurerm_mssql_database.cbd_app_sql_database`
  before the first apply. Check for any storage data that also needs a copy. Run the
  plan against CI state and verify it targets the new environment before applying.
- Add the CI frontend IP to the NanoPi's non-production WireGuard routing and peer
  `AllowedIPs`. Point the new proxy hosts at that private frontend on TCP 443, with
  the CI hostname as upstream SNI and certificate verification enabled. Verify the
  gateway, both public HTTPS hostnames, the blog API and sign-in before retiring Dev.
  The existing Dev state, data and proxy path provide a rollback point during cutover.

# terraform
This folder contains the terraform used to provission the acual environments and all its associated infrastructure.

# Key Vault Manual Secrets
## Secrets
```bash
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-ci-jwt-private-key" --value 'Jwt_Private_Key'
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-jwt-private-key" --value 'Jwt_Private_Key'
#https://learn.microsoft.com/en-gb/aspnet/core/security/authentication/social/google-logins
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-ci-google-client-id" --value "Google_Client_Id"
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-ci-google-client-secret" --value "Google_Client_Secret"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-google-client-id" --value "Google_Client_Id"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-google-client-secret" --value "Google_Client_Secret"
#https://learn.microsoft.com/en-gb/aspnet/core/security/authentication/social/microsoft-logins
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-ci-microsoft-client-id" --value "Microsoft_Client_Id"
az keyvault secret set --vault-name "cbd-enterprise-kv" --name "cbd-nonprod-ci-microsoft-client-secret" --value "Microsoft_Client_Secret"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-microsoft-client-id" --value "Microsoft_Client_Id"
az keyvault secret set --vault-name "cbd-premium-kv" --name "cbd-prod-live-microsoft-client-secret" --value "Microsoft_Client_Secret"
```
