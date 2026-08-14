# State split and rollout

This change creates a new state boundary; it does not transfer AKS or `vm01`
into the K3s state.

## Ownership after the change

```text
state.tfstate
├── AKS and the existing Kubernetes/Helm resources
└── module.shared: polinetworkbackups, backup containers, retention, budgets

k3s.tfstate
└── k3s01, K3s network/NAT, data disks, identities, RBAC, and three RBAC vaults
```

The K3s root uses data sources for the resource group and existing Blob
resources. A shared Azure resource must never be imported into both states.

## Preconditions

1. Confirm Blob versioning and soft delete on the `terraform-state` container.
2. Pull a local backup of the historical state and protect it as sensitive.
3. Verify that the current historical plan is converged before applying this
   refactor.
4. Verify that `Standard_E2ps_v6` is available to this subscription in the
   selected zone. At authoring time Azure returned no matching SKU for the
   current subscription, so this is an apply blocker until quota/availability
   is confirmed; do not silently select an x86 or larger fallback.

```bash
terraform -chdir=environments/legacy state pull > legacy-before-split.tfstate
chmod 600 legacy-before-split.tfstate

az vm list-skus \
  --location westeurope \
  --resource-type virtualMachines \
  --size Standard_E2ps_v6 \
  --zone --all \
  --query "[].{name:name,zones:locationInfo[0].zones,restrictions:restrictions}"
```

State backups (`*.tfstate`) and saved plans (`*.tfplan`) are ignored by Git and
must not be attached to a pull request because they can contain sensitive data.

## One-time rollout order

1. Review both PR plans. The legacy plan must show the seven retained-resource
   address moves, the approved failed-test deletions, and no replacement or
   deletion of shared storage.
2. Apply `environments/k3s` first. This creates `snet-k3s`; the target is not
   ready for workloads yet.
3. Apply `environments/legacy`. Its `moved` blocks retain the shared resources,
   the storage firewall switches from `snet-services` to `snet-k3s`, and the
   failed migration resources are destroyed.
4. Re-run plans for both roots. Each must report `No changes` before Ansible or
   Flux is allowed to use the host.

No manual `terraform state mv` is required for this refactor. The declarative
`moved` blocks perform the address changes inside the existing `state.tfstate`.

## Why the target includes a NAT public IP

The VM NIC has no public IP and the NSG denies all inbound traffic. K3s still
needs outbound HTTPS for Debian updates, GHCR, GitHub, Azure, and Cloudflare.
New Azure private subnets no longer receive implicit outbound connectivity, so
the root creates an outbound-only NAT Gateway and public IP. The NAT does not
accept unsolicited inbound connections. Its cost must be included in the final
budget approval.

## Approved cleanup of the failed attempt

The owner explicitly approved destruction of the previous migration test. The
inspected historical-state plan contains exactly 15 deletes:

- `vm01`, its implicit OS disk, `vnet-main`, `snet-services`, NSG, NIC and PIP;
- `disk-core`, `disk-services`, and both VM data-disk attachments;
- the old backup-container role assignment;
- `id-vm01-openbao`, `id-vm01-backup`, their two Key Vault access policies, and
  the `openbao-unseal` key.

The same plan retains `azurerm_resource_group.rg`, AKS,
`module.storageaccount`, `module.shared`, `module.keyvault`,
`polinetworkbackups`, both backup containers, retention policies, and budgets.
The data disks are destroyed without snapshots and must be treated as
irrecoverable after apply.
