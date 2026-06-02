terraform {
  required_version = ">= 1.10.0"

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.29.1"
    }
  }

  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/82330927/terraform/state/tailscale"
    lock_address   = "https://gitlab.com/api/v4/projects/82330927/terraform/state/tailscale/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/82330927/terraform/state/tailscale/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}

provider "tailscale" {
  // api_key             = var.tailscale_api_key
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet
}
