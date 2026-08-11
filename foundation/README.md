# ARM64 migration foundation

This Terraform root is intentionally independent from the AKS state. It creates
only the parallel migration foundation in the existing `rg-polinetwork` resource
group; it cannot delete or modify AKS.

## Fixed decisions

- `Standard_E2ps_v5` ARM64 VM in West Europe.
- Debian 13 ARM64 image version `0.20260810.2566`.
- VM name `vm01`.
- 32 GiB Standard SSD E4 OS disk named `disk-vm01-os`, 32 GiB Premium
  SSD P4 state disk named `disk-core`, and 64 GiB Standard SSD E6 services
  disk named `disk-services`. All three use ext4.
- VNet `vnet-main` (`10.42.0.0/16`) with private subnet `snet-services`
  (`10.42.1.0/24`), and VM private address `10.42.1.4` on `nic-vm01`.
- Standard static public IP `pip-vm01` provides explicit outbound connectivity
  only. The subnet-level `nsg-services` has an explicit deny-all inbound rule;
  no host port, including SSH, is exposed publicly.
- Debian uses a 4 GiB swap file with swappiness 10. SSH permits only the
  `pnadmin` public key; root, password and keyboard-interactive login are
  disabled. The Azure NSG is the host's network firewall, avoiding a second
  ruleset that could conflict with Docker networking.
- Azure performs daily patch assessment. Debian installs security updates with
  `unattended-upgrades`, but automatic operating-system reboots are disabled.
- Separate Cool ZRS storage account `polinetworkbackups` with a private
  `backups` container, blob versioning, 30-day soft deletion, 30-day unlocked
  immutable retention and 90-day lifecycle retention.
- The storage firewall permits the `snet-services` service endpoint only;
  anonymous access and shared keys are disabled. A dedicated user-assigned
  identity `id-vm01-backup` receives `Storage Blob Data Contributor` only on
  the backup container.
- Resource-group budget is USD 166/month, with actual alerts at 80% and 100%
  and a forecast alert at 100%.

The public IP is not an administration endpoint. Normal SSH access will traverse
Cloudflare Zero Trust and the outbound-only Cloudflare Tunnel. Bootstrap and
recovery use Azure Run Command/Serial Console until that authenticated path is
available. The SSH key is break-glass material; there is no public SSH NSG rule.
Its private key is stored as `compose-vm-ssh-private-key` in Azure Key Vault.
Terraform reads only `compose-vm-ssh-public-key` from the same vault. The
repository and its automation depend only on organization-owned Azure resources.

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

Cloud-init applies the host-level kernel settings and installs an idempotent
systemd oneshot service that waits for both data disks. The service formats a
disk only when no filesystem exists, verifies existing filesystems before
mounting, and therefore does not overwrite a restored disk. Docker, Komodo,
OpenBao, Traefik, cloudflared and observability belong to the separately
versioned platform stage; no bootstrap secret is stored in Terraform state.
