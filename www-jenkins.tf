data "template_file" "default_nginx_test" {
  template = file("${path.module}/nginx.tpl")

  vars = {
    domain = var.domain
  }
}

# create new SSH key
resource "digitalocean_ssh_key" "default" {
  name       = "Jenkins SSH"
  public_key = file(var.pub_key)
}

resource "digitalocean_droplet" "www-jenkins" {
  image              = "ubuntu-18-04-x64"
  name               = "www-jenkins"
  region             = "nyc3"
  size               = "512mb"
  private_networking = true
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  provisioner "file" {
    source      = "install-jenkins.sh"
    destination = "/tmp/install-jenkins.sh"
  }

  provisioner "file" {
    source      = "install-plugins.sh"
    destination = "/tmp/install-plugins.sh"
  }

#  provisioner "file" {
#    source      = "plugins.txt"
#    destination = "/tmp/plugins.txt"
#  }

  provisioner "file" {
    source      = "jenkins.yaml"
    destination = "/tmp/jenkins.yaml"
  }

  provisioner "file" {
    content      = data.template_file.default_nginx_test.rendered
    destination = "/tmp/jenkins-nginx-conf"
  }  

  connection {
    user        = "root"
    host        = digitalocean_droplet.www-jenkins.ipv4_address
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-jenkins.sh",
      "/tmp/install-jenkins.sh",
    ]
  }

}
