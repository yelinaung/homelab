# Tailscale Terraform

This directory is the Terraform entrypoint for managing the existing Tailscale tailnet in this repo.

## Authentication

Prefer environment variables for credentials:

```bash
export TAILSCALE_OAUTH_CLIENT_ID="..."
export TAILSCALE_OAUTH_CLIENT_SECRET="tskey-client-..."
```

Alternatively:

```bash
export TAILSCALE_API_KEY="tskey-api-..."
```

Set the tailnet in `values.tfvars`:

```hcl
tailscale_tailnet = "example.com"
```

## Managed resources

This module is currently set up to manage:

1. `tailscale_tailnet_settings`
2. `tailscale_contacts`

Both resources are gated by variables so they are only created once you copy the live values into `values.tfvars`.

## Commands

From the repo root:

```bash
mise run init-tailscale
mise run fmt-tailscale
mise run plan-tailscale
```

For imports:

```bash
MODULE='tailscale_tailnet_settings.main[0]' ID=tailnet_settings mise run import-tailscale
MODULE='tailscale_contacts.main[0]' ID=contacts mise run import-tailscale
```

## Adoption flow

1. Copy `values.tfvars.example` to `values.tfvars`.
2. Fill `tailscale_tailnet_settings` and `tailscale_contacts` with the current live values from the Tailscale admin console.
3. Run `mise run init-tailscale`.
4. Import tailnet settings:
   `MODULE='tailscale_tailnet_settings.main[0]' ID=tailnet_settings mise run import-tailscale`
5. Import contacts:
   `MODULE='tailscale_contacts.main[0]' ID=contacts mise run import-tailscale`
6. Run `mise run plan-tailscale` and confirm the plan is no-op before applying anything.
