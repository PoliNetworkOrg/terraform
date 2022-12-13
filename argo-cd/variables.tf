variable "namespace" {
  default = "argocd"
}

variable "applications" {
  type        = list(string)
  nullable    = true
  description = "List of applications to deploy, see https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps"
}
