terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"

  tags {
    Name = "Terraform main VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = "true"

  tags {
    Name = "Terraform main VPC, public subnet"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Terraform internet gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Public route table"
  }

}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow outbound traffic"

  vpc_id = "${aws_vpc.main.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQHT5o3Ss9X8YT/TaO8KrSCuZ+gOnNxHDQjAcxaQJwB4h4uLTvPvrN08upqUGhawtkBqehtEanUR6xqIqVW2iKR1KHTwEELNeHfKGnNenSK0zq6lBEnPaSL7cYbD7HnVYF5OAD82SC5ztbWT/9KyvDGUFmbAxsQgd7xy8HMbnAzKUGTvtmDYR1tXuezqh2eCIFZ+rumhvYLnsWoLmTF34VDuti9R04b26VeW70LwV2Es9jeS9kYv1jHQ6JalV3dzAtrPBJb1AhlS1z18rIw6FmJFNRq6wbobCRMcbmj45gahmOxK5ep4t3Xk0/nN5lez0o7KBsx3is2pSCiWocRxNLvk66Xzkrk49NYyKbYCKIb8nBh6ZSh7P8fk4LrGFcO5LFxFI3Y43KTq/Ron7Nr0lhSDrCgigluQpQRegU7j8OksD/Mwiw/ERMdy84RyTLS46dxx5M/WTr1tgWeiDwDu1azyj/6uZG5EaaPqQLucD1jYRhgTl7mi9J5OJ85Ec8LSxhpPjehJPcU3hWZCFM+xVFK8oab1jIfNoDrqaw1NqU+Kpo5/1zW09jNAYgRCqNwWt3nunY056Q+WTJr1scr2pkbMYYINgVgIRSRXRefhFKa6BrxgGAZO/wu2B6/b2scfO6pemqUfPAvk/nwYaQWGhEK/OG1eAT97utEiK4ezWAjQ== gstlt@apartmentbadger"
}

resource "aws_instance" "ssh_host" {
  ami           = "ami-0bdf93799014acdc4"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.admin.key_name}"

  subnet_id = "${aws_subnet.public.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  user_data = <<EOF
#!/bin/bash

echo "Hello user_data" >> /tmp/userdata.txt

EOF

  tags {
    Name = "SSH bastion"
  }
}

output "SSH_BASTION_IP" {
  value = "${aws_instance.ssh_host.public_ip}"
}
