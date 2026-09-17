resource "kubernetes_daemon_set_v1" "multipath_exclusion" {
  metadata {
    name      = "longhorn-multipath-exclusion"
    namespace = local.namespace
  }

  spec {
    selector {
      match_labels = { app = "longhorn-multipath-exclusion" }
    }
    template {
      metadata {
        labels = { app = "longhorn-multipath-exclusion" }
        annotations = {
          "configuration-checksum" = filesha256("${path.module}/scripts/exclude-multipath.sh")
        }
      }
      spec {
        host_pid                        = true
        automount_service_account_token = false
        node_selector                   = { "kubernetes.io/os" = "linux" }
        toleration {
          operator = "Exists"
        }
        init_container {
          name  = "exclude-longhorn-devices"
          image = "longhornio/longhorn-manager@sha256:f936764ef7a3df93893d7d454e2a0879979305c7d6b71a36ffecc5b4d1208abb"
          command = [
            "nsenter", "--mount=/host/proc/1/ns/mnt", "--net=/host/proc/1/ns/net",
            "--root=/host/proc/1/root", "--", "/bin/sh", "-c",
            file("${path.module}/scripts/exclude-multipath.sh")
          ]
          security_context {
            privileged  = true
            run_as_user = 0
          }
          volume_mount {
            name       = "host"
            mount_path = "/host"
            read_only  = true
          }
          resources {
            requests = { cpu = "10m", memory = "32Mi" }
            limits   = { memory = "128Mi" }
          }
        }
        container {
          name    = "configured"
          image   = "longhornio/longhorn-manager@sha256:f936764ef7a3df93893d7d454e2a0879979305c7d6b71a36ffecc5b4d1208abb"
          command = ["/bin/sleep", "2147483647"]
          security_context {
            run_as_user                = 65534
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
          resources {
            requests = { cpu = "1m", memory = "8Mi" }
            limits   = { memory = "32Mi" }
          }
        }
        volume {
          name = "host"
          host_path {
            path = "/"
            type = "Directory"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.longhorn]
}
