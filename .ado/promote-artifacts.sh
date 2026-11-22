#!/usr/bin/env bash
set -euo pipefail

if [[ "$SOURCE_REGISTRY" == "$TARGET_REGISTRY" ]]; then
  echo "Source and production registries must be different." >&2
  exit 1
fi

get_digest() {
  az acr repository show --subscription "$1" --name "$2" --image "$3" \
    --query digest --output tsv --only-show-errors
}

target_subscription=$(az account show --query id --output tsv --only-show-errors)
az acr show --name "$TARGET_REGISTRY" --resource-group "$TARGET_RESOURCE_GROUP" \
  --subscription "$target_subscription" --only-show-errors --output none

# Promote the pins from the deployment, including migration images and OCI charts.
artifacts=(
  "$BLOGS_SERVICE:$BLOGS_VERSION" "$BLOGS_SERVICE-data:$BLOGS_VERSION" "helm/$BLOGS_SERVICE:$BLOGS_VERSION"
  "$IDENTITY_SERVICE:$IDENTITY_VERSION" "$IDENTITY_SERVICE-data:$IDENTITY_VERSION" "helm/$IDENTITY_SERVICE:$IDENTITY_VERSION"
  "$WEB_SERVICE:$WEB_VERSION" "helm/$WEB_SERVICE:$WEB_VERSION"
)

source_digests=()
for artifact in "${artifacts[@]}"; do
  if [[ ! "$artifact" =~ :[0-9]+\.[0-9]+\.[0-9]+([.-][a-zA-Z0-9._-]+)?$ ]]; then
    echo "Expected a pinned release version: $artifact" >&2
    exit 1
  fi
  digest=$(get_digest "$SOURCE_SUBSCRIPTION" "$SOURCE_REGISTRY" "$artifact")
  if [[ ! "$digest" =~ ^sha256:[a-f0-9]{64}$ ]]; then
    echo "Could not resolve the source digest for $artifact." >&2
    exit 1
  fi
  source_digests+=("$digest")
done

# Older charts embed the non-prod registry. Fail before writing anything to prod
# unless each chart renders all of its pinned images from the target registry.
az acr login --subscription "$SOURCE_SUBSCRIPTION" --name "$SOURCE_REGISTRY" --only-show-errors
target_host="$TARGET_REGISTRY.azurecr.io"
for release in "$BLOGS_SERVICE:$BLOGS_VERSION" "$IDENTITY_SERVICE:$IDENTITY_VERSION" "$WEB_SERVICE:$WEB_VERSION"; do
  service=${release%:*}
  version=${release##*:}
  expected=("$target_host/$service:$version")
  if [[ "$service" != "$WEB_SERVICE" ]]; then
    expected+=("$target_host/$service-data:$version")
  fi
  rendered=$(helm template "live-$service" "oci://$SOURCE_REGISTRY.azurecr.io/helm/$service" \
    --version "$version" --namespace cbd-prod-live \
    --set-string "env.name=live,env.shortName=live,imageRegistry=$target_host")
  actual_images=$(awk '$1 == "image:" { gsub(/"/, "", $2); print $2 }' <<< "$rendered" | sort)
  expected_images=$(printf '%s\n' "${expected[@]}" | sort)
  if [[ "$actual_images" != "$expected_images" ]]; then
    echo "Chart $release must render all pinned images from $target_host. Rebuild and pin a chart that supports the imageRegistry value." >&2
    exit 1
  fi
done

for index in "${!artifacts[@]}"; do
  artifact=${artifacts[index]}
  digest=${source_digests[index]}
  target_digest=$(get_digest "$target_subscription" "$TARGET_REGISTRY" "$artifact" 2>/dev/null || true)
  if [[ -z "$target_digest" ]]; then
    # The default import mode refuses to overwrite a published production tag.
    if ! az acr import --subscription "$target_subscription" --name "$TARGET_REGISTRY" \
      --resource-group "$TARGET_RESOURCE_GROUP" --registry "$SOURCE_REGISTRY_ID" \
      --source "${artifact%:*}@$digest" --image "$artifact" --only-show-errors; then
      echo "Import did not complete for $artifact. Checking whether another run published it."
    fi
    target_digest=$(get_digest "$target_subscription" "$TARGET_REGISTRY" "$artifact")
  fi
  if [[ "$target_digest" != "$digest" ]]; then
    echo "Production $artifact has a different digest. The existing tag will not be overwritten." >&2
    exit 1
  fi
  echo "Verified $TARGET_REGISTRY/$artifact at $digest"
done
