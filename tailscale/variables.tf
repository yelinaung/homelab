variable "tailscale_oauth_client_id" {
  type      = string
  sensitive = true
  default   = null

  validation {
    condition     = var.tailscale_oauth_client_id == null || trimspace(var.tailscale_oauth_client_id) != ""
    error_message = "tailscale_oauth_client_id must be null or a non-empty string."
  }
}

variable "tailscale_oauth_client_secret" {
  type      = string
  sensitive = true
  default   = null

  validation {
    condition     = var.tailscale_oauth_client_secret == null || trimspace(var.tailscale_oauth_client_secret) != ""
    error_message = "tailscale_oauth_client_secret must be null or a non-empty string."
  }
}

variable "tailscale_tailnet" {
  type    = string
  default = "-"

  validation {
    condition     = trimspace(var.tailscale_tailnet) != ""
    error_message = "tailscale_tailnet must not be empty. Use \"-\" to target the provider default tailnet."
  }
}

variable "tailscale_contacts" {
  type = object({
    account_email  = string
    support_email  = string
    security_email = string
  })
  sensitive = true
  default   = null

  validation {
    condition = var.tailscale_contacts == null || alltrue([
      for email in [
        var.tailscale_contacts.account_email,
        var.tailscale_contacts.support_email,
        var.tailscale_contacts.security_email
      ] : length(regexall("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", trimspace(email))) > 0
    ])
    error_message = "tailscale_contacts must contain valid account, support, and security email addresses."
  }
}

variable "tailscale_tailnet_settings" {
  type = object({
    acls_external_link                          = optional(string)
    acls_externally_managed_on                  = optional(bool)
    devices_approval_on                         = optional(bool)
    devices_auto_updates_on                     = optional(bool)
    devices_key_duration_days                   = optional(number)
    https_enabled                               = optional(bool)
    network_flow_logging_on                     = optional(bool)
    posture_identity_collection_on              = optional(bool)
    regional_routing_on                         = optional(bool)
    users_approval_on                           = optional(bool)
    users_role_allowed_to_join_external_tailnet = optional(string)
  })
  default = null

  validation {
    condition = var.tailscale_tailnet_settings == null || (
      try(var.tailscale_tailnet_settings.acls_external_link, null) == null ||
      can(regex("^https?://", var.tailscale_tailnet_settings.acls_external_link))
    )
    error_message = "tailscale_tailnet_settings.acls_external_link must be null or an http/https URL."
  }

  validation {
    condition = var.tailscale_tailnet_settings == null || (
      try(var.tailscale_tailnet_settings.devices_key_duration_days, null) == null ||
      var.tailscale_tailnet_settings.devices_key_duration_days > 0
    )
    error_message = "tailscale_tailnet_settings.devices_key_duration_days must be greater than 0 when set."
  }

  validation {
    condition = var.tailscale_tailnet_settings == null || (
      try(var.tailscale_tailnet_settings.users_role_allowed_to_join_external_tailnet, null) == null ||
      trimspace(var.tailscale_tailnet_settings.users_role_allowed_to_join_external_tailnet) != ""
    )
    error_message = "tailscale_tailnet_settings.users_role_allowed_to_join_external_tailnet must be null or a non-empty string."
  }
}
