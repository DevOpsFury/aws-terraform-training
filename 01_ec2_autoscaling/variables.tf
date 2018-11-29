variable "region" {
  type    = "string"
  default = "eu-central-1"
}

variable "ssh_access_from_cidr" {
  description = "Access from to ssh from these IPs"
  type        = "list"
  default     = ["10.100.0.0/16"]
}

variable "associate_public_ip_address" {
  default = true
}

variable "instance_type" {
  description = "Instance type"
  default     = "t2.small"
}

variable "ssh_key" {
  description = "SSH key used for connecting to the EC2 instance"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQHT5o3Ss9X8YT/TaO8KrSCuZ+gOnNxHDQjAcxaQJwB4h4uLTvPvrN08upqUGhawtkBqehtEanUR6xqIqVW2iKR1KHTwEELNeHfKGnNenSK0zq6lBEnPaSL7cYbD7HnVYF5OAD82SC5ztbWT/9KyvDGUFmbAxsQgd7xy8HMbnAzKUGTvtmDYR1tXuezqh2eCIFZ+rumhvYLnsWoLmTF34VDuti9R04b26VeW70LwV2Es9jeS9kYv1jHQ6JalV3dzAtrPBJb1AhlS1z18rIw6FmJFNRq6wbobCRMcbmj45gahmOxK5ep4t3Xk0/nN5lez0o7KBsx3is2pSCiWocRxNLvk66Xzkrk49NYyKbYCKIb8nBh6ZSh7P8fk4LrGFcO5LFxFI3Y43KTq/Ron7Nr0lhSDrCgigluQpQRegU7j8OksD/Mwiw/ERMdy84RyTLS46dxx5M/WTr1tgWeiDwDu1azyj/6uZG5EaaPqQLucD1jYRhgTl7mi9J5OJ85Ec8LSxhpPjehJPcU3hWZCFM+xVFK8oab1jIfNoDrqaw1NqU+Kpo5/1zW09jNAYgRCqNwWt3nunY056Q+WTJr1scr2pkbMYYINgVgIRSRXRefhFKa6BrxgGAZO/wu2B6/b2scfO6pemqUfPAvk/nwYaQWGhEK/OG1eAT97utEiK4ezWAjQ=="
}

# Autoscaling group sizing
variable "min_size" {
  type    = "string"
  default = "1"
}

variable "max_size" {
  type    = "string"
  default = "3"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}
