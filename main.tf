terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins2" {
  image    = "ubuntu-18-04-x64"
  name     = "jenkins2"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.devopselite.id]
}

data "digitalocean_ssh_key" "devopselite" {
  name = var.ssh_key_name
}

## Cluster Kubernetes

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""
}

variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

output "jenkins2_ip" {
  value = digitalocean_droplet.jenkins2.ipv4_address
}

resource "local_file" "foo" {
    content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}



