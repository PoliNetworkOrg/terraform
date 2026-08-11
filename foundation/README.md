# ARM64 migration foundation

This Terraform root is intentionally independent from the AKS state. It creates
only the parallel migration foundation in the existing `rg-polinetwork` resource
group; it cannot delete or modify AKS.

## Fixed decisions

- `Standard_E2ps_v5` ARM64 VM in West Europe.
- Ubuntu 22.04 ARM64 image version `22.04.202608060`.
- 32 GiB Standard SSD OS disk, 32 GiB Premium P4 state disk and 32 GiB
  Standard SSD E4 application disk.
- One Standard static public IP for explicit outbound connectivity. The NSG has
  an explicit deny-all inbound rule and no host port is exposed.
- Separate Cool LRS backup account, OAuth-only access, blob versioning, 14-day
  immutable retention and 90-day lifecycle retention.
- VM system-assigned identity receives `Storage Blob Data Contributor` only on
  the backup container.
- Resource-group budget is USD 166/month, with actual alerts at 80% and 100%
  and a forecast alert at 100%.

The public IP is not an administration endpoint. Bootstrap and recovery use
Azure Run Command/Serial Console until the authenticated management path is in
place. The SSH key is break-glass material; there is no SSH NSG rule. Its private
key is stored as `compose-vm-ssh-private-key` in Azure Key Vault. Terraform reads
only `compose-vm-ssh-public-key` from the same vault. The repository and its
automation depend only on organization-owned Azure resources.

## State isolation

The backend key is `migration-foundation.tfstate`; the existing AKS root keeps
using `state.tfstate`. Never move AKS resources into this state and never run a
combined create/destroy apply.

## Validation and first plan

```bash
cp terraform.tfvars.example terraform.tfvars
# Confirm the budget date and recipients.
source ../access_key.sh
terraform init
terraform validate
terraform plan -out foundation.tfplan
terraform show foundation.tfplan
```

Do not apply until the plan shows only the resources declared in this directory,
the Azure price check remains within the migration budget, and the operator has
confirmed the exact SSH public key. `terraform.tfvars` and plan files must remain
untracked.

Cloud-init applies the host-level kernel settings. A Custom Script extension
runs only after both data disks are attached; it formats disks only when no
filesystem exists, verifies existing filesystems before mounting, and therefore
does not overwrite a restored disk. Docker, Komodo, OpenBao, Traefik,
cloudflared and observability belong to the separately versioned platform stage;
no bootstrap secret is stored in Terraform state.
