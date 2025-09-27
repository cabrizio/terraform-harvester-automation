terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = ">= 1.6.0"
    }
  }
}
provider "harvester" {
  # Path to kubeconfig file
  kubeconfig = "~/.kube/configs/harvester.yaml"

  kubecontext = "harvester"
}

terraform {
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}
