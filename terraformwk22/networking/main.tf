# -- networking/main.tf

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "Week22_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Week22_vpc-${random_integer.random.id}"
  }
}

#Create the Public Subnets
resource "aws_subnet" "publicsub_1" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.Week22_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "publicsub_1${count.index + 1}"
  }
}

#Connect the Public Subnets to the Route Table
resource "aws_route_table_association" "project_rt" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.publicsub_1.*.id[count.index]
  route_table_id = aws_route_table_association.project_rt[count.index]
}

#Create the Private Subnets
resource "aws_subnet" "privatesub_1" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.Week22_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "privatesub_1${count.index + 1}"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Week22_vpc.id

  tags = {
    Name = "igw"
  }
}

#Create NAT Gateway
resource "aws_eip" "nat_gw" {}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.publicsub_1[1].id

  tags = {
    Name = "wk22_nat_gw"
  }
}

#Route Table for Public Subnets
resource "aws_route_table" "public_route_1" {
  vpc_id = aws_vpc.Week22_vpc.id

  tags = {
    Name = "public_route_1"
  }
}

resource "aws_default_route_table" "default_public_rt" {
  default_route_table_id = aws_vpc.Week22_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.Week22_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_default_route_table" "default_private_rt" {
  default_route_table_id = aws_vpc.Week22_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}

#Create Security group
resource "aws_security_group" "bastion_pub_sg" {
  name        = "bastion_pub_sg"
  description = "Security group to allow SSH inbound traffic to bastion host"
  vpc_id      = aws_vpc.Week22_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "HTTP traffic from lb and SSH traffic from bastion host"
  vpc_id      = aws_vpc.Week22_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_pub_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Security group to allow inbound HTTP traffic"
  vpc_id      = aws_vpc.Week22_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}