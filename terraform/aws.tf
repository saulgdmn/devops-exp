provider "aws"{

}

data "aws_ami" "ubuntu_latest" {
    owners = ["099720109477"]
    name_regex = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    most_recent = true
}

data "aws_key_pair" "ssh_key" {
    key_name = "ssh-key"
}

locals {
    ingress_ports = [22, 3000, 9090]
}

resource "aws_security_group" "default"{
    name = "Allow SSH"

    ingress {
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "monitoring"{
    name = "Allow SSH, Grafana and Prometheus"

    dynamic "ingress"{
        for_each = local.ingress_ports
        content {
            to_port = ingress.value
            from_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}


resource "aws_instance" "monitoring"{
    instance_type = "t2.micro"
    ami = data.aws_ami.ubuntu_latest.id
    vpc_security_group_ids = [aws_security_group.monitoring.id]
    key_name = data.aws_key_pair.ssh_key.key_name
}

resource "aws_instance" "app"{
    instance_type = "t2.micro"
    ami = data.aws_ami.ubuntu_latest.id
    vpc_security_group_ids = [aws_security_group.default.id]
    key_name = data.aws_key_pair.ssh_key.key_name
}

output "ubuntu_latest_id"{
    value = data.aws_ami.ubuntu_latest.id
}

output "monitoring_server_public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "app_server_public_ip" {
  value = aws_instance.app.public_ip
}