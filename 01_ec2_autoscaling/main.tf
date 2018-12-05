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

# Public subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1a"

  tags {
    Name = "Terraform main VPC, public subnet zone A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.100.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1b"

  tags {
    Name = "Terraform main VPC, public subnet zone B"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.100.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1c"

  tags {
    Name = "Terraform main VPC, public subnet zone C"
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

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = "${aws_subnet.public_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Private subnets
resource "aws_subnet" "private_a" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.100.10.0/24"
    map_public_ip_on_launch = false

    availability_zone = "eu-central-1a"

  tags {
    Name = "Terraform main VPC, private subnet zone A"
  }
}

resource "aws_subnet" "private_b" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.100.11.0/24"
    map_public_ip_on_launch = false

    availability_zone = "eu-central-1b"

  tags {
    Name = "Terraform main VPC, private subnet zone B"
  }
}

resource "aws_subnet" "private_c" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.100.12.0/24"
    map_public_ip_on_launch = false

    availability_zone = "eu-central-1c"

  tags {
    Name = "Terraform main VPC, private subnet zone C"
  }
}

resource "aws_eip" "nateip" {
  vpc   = true
  count = "3"
}

resource "aws_nat_gateway" "natgw_a" {
  allocation_id = "${element(aws_eip.nateip.*.id, 0)}"
  subnet_id     = "${aws_subnet.public_a.id}"

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "natgw_b" {
  allocation_id = "${element(aws_eip.nateip.*.id, 1)}"
  subnet_id     = "${aws_subnet.public_b.id}"

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_nat_gateway" "natgw_c" {
  allocation_id = "${element(aws_eip.nateip.*.id, 2)}"
  subnet_id     = "${aws_subnet.public_c.id}"

  depends_on = ["aws_internet_gateway.default"]
}

resource "aws_route_table" "private_a" {
  vpc_id           = "${aws_vpc.main.id}"

    tags {
        Name = "Private route table, zone A"
    }
}

resource "aws_route_table" "private_b" {
  vpc_id           = "${aws_vpc.main.id}"

    tags {
        Name = "Private route table, zone B"
    }
}

resource "aws_route_table" "private_c" {
  vpc_id           = "${aws_vpc.main.id}"

    tags {
        Name = "Private route table, zone C"
    }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = "${element(aws_subnet.private_a}"
  route_table_id = "${element(aws_route_table.private_a.id}"
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${element(aws_subnet.private_b}"
  route_table_id = "${element(aws_route_table.private_b.id}"
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = "${element(aws_subnet.private_c}"
  route_table_id = "${element(aws_route_table.private_c.id}"
}

resource "aws_route" "private_nat_gateway_a" {
  route_table_id         = "${aws_route_table.private_a.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.natgw_a.id}"
}

resource "aws_route" "private_nat_gateway_b" {
  route_table_id         = "${aws_route_table.private_b.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.natgw_b.id}"
}

resource "aws_route" "private_nat_gateway_c" {
  route_table_id         = "${aws_route_table.private_c.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.natgw_c.id}"
}

################ end private subnets stuff

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
  public_key = "${var.ssh_key}"
}

resource "aws_instance" "ssh_host" {
  ami           = "ami-0bdf93799014acdc4"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.admin.key_name}"

  subnet_id = "${aws_subnet.public_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  tags {
    Name = "SSH bastion"
  }
}
