## Terrafom provider for harvester required version

terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = ">= 1.6.0"
    }
  }
}
