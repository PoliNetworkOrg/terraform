# PoliNetwork Azure infrastructure

Terraform is split into independent root modules. A root owns its resources;
other roots can only consume them through data sources or explicit outputs.

| Root | Backend key | Ownership |
|---|---|---|
| `environments/legacy` | `state.tfstate` | Existing AKS platform, Kubernetes/Helm resources, `vm01`, and retained shared resources |
| `environments/k3s` | `k3s.tfstate` | New single-node K3s target only |

Moving the historical root into `environments/legacy` does not move or clone
its state. Its backend key and all Terraform resource addresses remain the
same. The `moved` blocks in that root extract `polinetworkbackups`, its
containers, retention policy, and resource-group budgets from the retired
`module.foundation` into `module.shared` without recreating them. The remaining
foundation resources are explicitly deleted as the failed migration test.

The K3s root reads `rg-polinetwork`, `polinetworksa/file-blobs`, and
`polinetworkbackups/backups` as data sources. It must never import or declare
those shared objects as resources.

## Local checks

Authenticate with Azure and provide the provider subscription explicitly:

```bash
az login
az account set --subscription <subscription-id>
export ARM_SUBSCRIPTION_ID=<subscription-id>
export TF_VAR_subscription_id="$ARM_SUBSCRIPTION_ID"

terraform -chdir=environments/legacy init -backend-config=use_oidc=false
terraform -chdir=environments/legacy validate
terraform -chdir=environments/k3s init -backend-config=use_oidc=false
terraform -chdir=environments/k3s validate
```

The signed-in principal needs Blob data-plane access to the
`terraform-state` container. If it does not have that RBAC role, load the
backend credential through the existing secure operator procedure before
running `init`; never pass an access key on the command line or commit it.

Do not use `terraform destroy` at repository level. Always select one root with
`-chdir` and inspect a saved plan before applying it.

## Delivery

Pull requests run format, initialization, validation, and plan for both roots,
then update one PR comment per environment. Pull requests cannot run apply. A
push to `stable` repeats both plans, then waits for approval through the GitHub
`production` environment before applying `k3s` followed by `legacy`.

See [STATE_MIGRATION.md](STATE_MIGRATION.md) for the one-time rollout sequence
and the guardrails for removing the failed `vm01` attempt.
