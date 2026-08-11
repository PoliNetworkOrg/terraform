# ARM64 migration foundation module

This module is part of the repository's single Terraform root and state. It is
instantiated alongside the existing Key Vault, Storage and AKS modules and adds
the infrastructure required for the Compose migration.

## Fixed decisions

- `Standard_E2ps_v6` ARM64 VM in West Europe with Trusted Launch.
- Debian 13 ARM64 image version `0.20260810.2566`.
- VM name `vm01`.
- 32 GiB Standard SSD E4 OS disk named `disk-vm01-os`, 32 GiB Premium
  SSD P4 state disk named `disk-core`, and 64 GiB Standard SSD E6 services
  disk named `disk-services`. All three use ext4.
- VNet `vnet-main` (`10.42.0.0/16`) with private subnet `snet-services`
  (`10.42.1.0/24`), and VM private address `10.42.1.4` on `nic-vm01`.
- Standard static public IP `pip-vm01` provides outbound connectivity and direct
  SSH administration. The subnet-level `nsg-services` permits public TCP/22 and
  explicitly denies every other inbound flow.
- Debian uses a 4 GiB swap file with swappiness 10. SSH permits only the
  `pnadmin` public key; root, password and keyboard-interactive login are
  disabled. The Azure NSG is the host's network firewall, avoiding a second
  ruleset that could conflict with Docker networking.
- Azure performs daily patch assessment. Debian installs security updates with
  `unattended-upgrades`, but automatic operating-system reboots are disabled.
- Separate Cool ZRS storage account `polinetworkbackups` with a private
  `backups` container, blob versioning, 30-day soft deletion, 30-day unlocked
  immutable retention and 90-day lifecycle retention.
- OS and data disks use Azure platform-managed encryption. Backup storage adds
  infrastructure encryption, while backup archives will be encrypted by the
  backup application. Customer-managed keys are intentionally excluded to
  avoid making VM and backup recovery depend on Key Vault availability.
- The storage firewall permits the `snet-services` service endpoint only;
  anonymous access and shared keys are disabled. A dedicated user-assigned
  identity `id-vm01-backup` receives `Storage Blob Data Contributor` only on
  the backup container.
- The resource group has a USD 140 monthly operating budget with actual alerts
  at 85%, 100% and 120%, plus a forecast alert at 100%. A separate USD 1,850
  annual safety budget preserves USD 150 of sponsorship contingency; it alerts
  on an 80% forecast and actual spend at 75%, 85%, 95% and 100%. Budgets notify
  `adminorg@polinetwork.org` and never stop resources automatically.

Normal administration uses direct SSH to the static public IP. TCP/22 is
reachable from any IPv4 address because administrators do not share a stable
source range, but sshd accepts only the `pnadmin` key: root, passwords and
keyboard-interactive authentication are disabled. Azure Run Command and Serial
Console remain recovery channels. The private key is stored as
`compose-vm-ssh-private-key` in Azure Key Vault. Terraform reads only
`compose-vm-ssh-public-key` from the same vault. The repository and its
automation depend only on organization-owned Azure resources.

## Validation and first plan

```bash
source ./access_key.sh
terraform init
terraform validate
terraform plan -out tfplan
terraform show tfplan
```

Do not apply until the unified root plan adds only the approved migration
resources, changes or destroys no existing resources, and the Azure price check
remains within the migration budget. Plan files must remain untracked.

Cloud-init applies the host-level kernel settings and installs an idempotent
systemd oneshot service that waits for both data disks. The service formats a
disk only when no filesystem exists, verifies existing filesystems before
mounting, and therefore does not overwrite a restored disk. Docker, Komodo,
OpenBao, Traefik, cloudflared and observability belong to the separately
versioned platform stage; no bootstrap secret is stored in Terraform state.
