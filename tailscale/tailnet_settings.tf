resource "tailscale_tailnet_settings" "main" {
  count = var.tailscale_tailnet_settings == null ? 0 : 1

  acls_external_link                          = try(var.tailscale_tailnet_settings.acls_external_link, null)
  acls_externally_managed_on                  = try(var.tailscale_tailnet_settings.acls_externally_managed_on, null)
  devices_approval_on                         = try(var.tailscale_tailnet_settings.devices_approval_on, null)
  devices_auto_updates_on                     = try(var.tailscale_tailnet_settings.devices_auto_updates_on, null)
  devices_key_duration_days                   = try(var.tailscale_tailnet_settings.devices_key_duration_days, null)
  https_enabled                               = try(var.tailscale_tailnet_settings.https_enabled, null)
  network_flow_logging_on                     = try(var.tailscale_tailnet_settings.network_flow_logging_on, null)
  posture_identity_collection_on              = try(var.tailscale_tailnet_settings.posture_identity_collection_on, null)
  regional_routing_on                         = try(var.tailscale_tailnet_settings.regional_routing_on, null)
  users_approval_on                           = try(var.tailscale_tailnet_settings.users_approval_on, null)
  users_role_allowed_to_join_external_tailnet = try(var.tailscale_tailnet_settings.users_role_allowed_to_join_external_tailnet, null)
}
