# get a domain and point it to:
# ns1.digitalocean.com.
# ns2.digitalocean.com.
# ns3.digitalocean.com.

# Create a new domain record
resource "digitalocean_domain" "default" {
   name = var.domain
   ip_address = digitalocean_droplet.www-jenkins.ipv4_address
}

resource "digitalocean_record" "CNAME-www" {
  domain = digitalocean_domain.default.name
  type = "CNAME"
  name = "www"
  value = "@"
}