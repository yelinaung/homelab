terraform {
  required_version = ">= 1.10.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/82330927/terraform/state/cloudflare"
    lock_address   = "https://gitlab.com/api/v4/projects/82330927/terraform/state/cloudflare/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/82330927/terraform/state/cloudflare/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
