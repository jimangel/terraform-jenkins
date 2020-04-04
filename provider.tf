variable "do_token" {
}

variable "domain" {
}

variable "pub_key" {
}

variable "pvt_key" {
}

variable "ssh_fingerprint" {
}

provider "digitalocean" {
  token = var.do_token
}