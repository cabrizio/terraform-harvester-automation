terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = ">= 1.6.0"
    }
  }

  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}

provider "harvester" {
  # Path to kubeconfig file
  kubeconfig  = "~/.kube/configs/hivemq-harvester.yaml"
  kubecontext = "hivemq-harvester"
}
