variable "cloudflare_api_token" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.cloudflare_api_token) > 0
    error_message = "Cloudflare API token must not be empty."
  }
}

variable "cloudflare_zone_id" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.cloudflare_zone_id))
    error_message = "Zone ID must be a 32-character hex string."
  }
}

variable "cloudflare_dns_records" {
  type = map(object({
    type     = string
    value    = string
    proxied  = optional(bool, true)
    ttl      = optional(number, 1)
    priority = optional(number, null)
  }))

  validation {
    condition = alltrue([
      for k, v in var.cloudflare_dns_records :
      contains(["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "CAA", "NS", "PTR"], v.type)
    ])
    error_message = "Record type must be one of: A, AAAA, CNAME, MX, TXT, SRV, CAA, NS, PTR."
  }

  validation {
    condition = alltrue([
      for k, v in var.cloudflare_dns_records :
      v.type != "MX" || v.priority != null
    ])
    error_message = "MX records must have a priority set."
  }

  validation {
    condition = alltrue([
      for k, v in var.cloudflare_dns_records :
      v.ttl == 1 || (v.ttl >= 60 && v.ttl <= 86400)
    ])
    error_message = "TTL must be 1 (automatic) or between 60 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for k, v in var.cloudflare_dns_records :
      !v.proxied || contains(["A", "AAAA", "CNAME"], v.type)
    ])
    error_message = "Only A, AAAA, and CNAME records can be proxied."
  }
}
