resource "tailscale_contacts" "main" {
  count = var.tailscale_contacts == null ? 0 : 1

  account {
    email = var.tailscale_contacts.account_email
  }

  support {
    email = var.tailscale_contacts.support_email
  }

  security {
    email = var.tailscale_contacts.security_email
  }
}
