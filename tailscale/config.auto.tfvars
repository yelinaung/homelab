# Non-secret Tailscale config. Tracked in git and reviewed in MRs.
# OAuth credentials live in secrets.auto.tfvars locally / TF_VAR_* in CI.
tailscale_tailnet = "TATvW1B7jM91CNTRL"

tailscale_tailnet_settings = {
  acls_externally_managed_on                  = false
  devices_approval_on                         = false
  devices_auto_updates_on                     = true
  devices_key_duration_days                   = 180
  https_enabled                               = true
  network_flow_logging_on                     = false
  posture_identity_collection_on              = false
  regional_routing_on                         = false
  users_approval_on                           = false
  users_role_allowed_to_join_external_tailnet = "admin"
}

tailscale_contacts = {
  account_email  = "me@yelinaung.com"
  support_email  = "me@yelinaung.com"
  security_email = "me@yelinaung.com"
}
