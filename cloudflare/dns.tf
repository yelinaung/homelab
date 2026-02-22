resource "cloudflare_dns_record" "records" {
  for_each = var.cloudflare_dns_records

  zone_id  = var.cloudflare_zone_id
  name     = split("__", each.key)[0]
  type     = each.value.type
  content  = sensitive(each.value.value)
  proxied  = each.value.proxied
  ttl      = each.value.proxied ? 1 : each.value.ttl
  priority = each.value.priority
}
