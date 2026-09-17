# Longhorn on one AKS node

This module keeps the existing Longhorn 1.8.1 chart and provisions one replica per
volume. A single node has no node failover; replicas on the same node do not add
that protection. Maintain external backups and plan downtime for node maintenance.

The privileged init container installs the observed `IET` / `VIRTUAL-DISK`
multipath exclusion on Linux nodes. It backs up existing configuration, preserves
other device rules, checks parsing and reloads multipathd. It never flushes maps,
detaches disks or changes filesystems. An already claimed, in-use map still needs
individual operator diagnosis. The host mount and privilege are required to edit
the host configuration. The idle container has no privileges or API token.

## Provisioning and backups

New volumes use one replica, `Retain`, the `azblob` backup target, and the existing
`default` recurring-job group. Prerequisites are the configured `azblob` target,
its credential secret and a backup recurring job in that group; this module does
not create or print credentials. In the audited cluster that target points to
`azblob://longhorn-backups@core.windows.net/`.

The pinned chart declares `persistence.backupTargetName` but omits it from its
StorageClass ConfigMap template. The postrenderer inserts that parameter and
fails if the expected template changes. Revisit it when upgrading the chart.

Longhorn's [1.8.1 ConfigMap controller](https://github.com/longhorn/longhorn-manager/blob/v1.8.1/controller/kubernetes_configmap_controller.go)
recreates the StorageClass when this ConfigMap changes. Bound PVs and PVCs remain
in place. Schedule the apply outside new-volume provisioning, inspect the plan,
and verify the recreated class before provisioning another claim. Existing PVs
and volume replica counts are not retroactively changed by these defaults.

## Rollout

Review a plan from the environment that owns this deployed Helm release. Do not
apply an unrelated environment or accept unrelated replacements. The node
configuration DaemonSet is created before the Helm update. Review its privileged
host access explicitly. After apply, verify the init container completed, the
StorageClass has the expected parameters, existing volumes remain healthy and
backup records complete without errors. Never delete a PVC or force-detach an
engine to make an apply succeed.

The incident's existing PVs were separately changed to `Retain`; all nine were
Bound. This protects against automatic reclamation, not direct disk deletion.
The Kubernetes manifest PR also prevents Argo from pruning the seven managed
Longhorn claims. PostgreSQL and MariaDB use Azure Disk and need separate backups.

## Validation

Run `python3 modules/longhorn/tests/test-scripts.py` and `terraform fmt -check
modules/longhorn`. Validate with the environment's pinned providers. Render chart
1.8.1 with the module's values and postrenderer; inspect the embedded
`longhorn-storageclass` ConfigMap for one replica, `Retain`, `azblob` and the
`default` recurring-job group. These checks do not authorize or perform an apply.
