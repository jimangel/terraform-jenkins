
output "ip" {
  value       = digitalocean_droplet.www-jenkins.ipv4_address
}

#output "file" {
#value = data.template_file.default_nginx_test.rendered
#}