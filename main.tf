module "argo_cd" {
  source = "./minikube/"

  applications = [
    file("./argocd-applications.yaml")
  ]

}