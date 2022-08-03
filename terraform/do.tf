terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

locals {
    ports = [22, 27017, 2181, 9093, 9100, 9216, 9308]
}

data "digitalocean_sizes" "default" {
    filter {
        key = "vcpus"
        values = [2]
    }
  
    filter {
        key = "memory"
        values = [4096]
    }

    sort {
        key = "price_monthly"
        direction = "asc"
    }
}

data "digitalocean_ssh_key" "default" {
    name = "ssh-key"
}

resource "digitalocean_droplet" "mongo_kafka" {
    image  = "ubuntu-18-04-x64"
    name   = "mongo-kafka"
    region = "fra1"
    size = element(data.digitalocean_sizes.default.sizes, 0).slug
    ssh_keys = [data.digitalocean_ssh_key.default.id]
}

resource "digitalocean_firewall" "mongo_kafka" {
    name = "mongo-kafka-fw"

    droplet_ids = [digitalocean_droplet.mongo_kafka.id]

    dynamic "inbound_rule"{
        for_each = local.ports
        content{
            protocol = "tcp"
            port_range = inbound_rule.value
            source_addresses = ["0.0.0.0/0", "::/0"]
        }
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}

output "mongo_kafka_public_ip" {
    value = digitalocean_droplet.mongo_kafka.ipv4_address
}

output "droplet_size" {
    value = element(data.digitalocean_sizes.default.sizes, 0).slug
}