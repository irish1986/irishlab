# flux

## bootstrap

Export `env` variables

```bash
    export GITHUB_TOKEN=${api_token} # token => all repo checked
    export GITHUB_USER=${username}
    export GITHUB_REPO=${repo}
```

Run the bootstrap commands

```bash
flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --path=k8s/cluster/homelab/base \
    --personal \
    --token-auth
```

Flux reconciliation after the bootstrap

```bash
flux reconcile kustomization flux-system --with-source
```

## How does it work?

`k8s/cluster/homelab/base` is the entrypoint. It holds Kustomizations for all the other 3 modules as well as the flux-system ( which is the flux installation )
Each Kustomization is a separate file with dependencies of one another.

`helm.yaml` - Holds all the helm charts needed.
`core.yaml` - Depends on helm Kustomization and holds core functionality for the cluster to function like storage, certificates, ingress, etc.
`apps.yaml` - Depends on both `core.yaml` and `helm.yaml` and holds all the apps currently installed on my cluster.
`configs.yaml` - Depends on `core.yaml` and holds all the configurations for the cluster
