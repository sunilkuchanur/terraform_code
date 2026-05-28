terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "terra_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terra_vpc"
  }
}

resource "aws_subnet" "terra_public_subnet01" {
  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terra_public_subnet01"
  }
}


resource "aws_subnet" "terra_public_subnet02" {
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terra_public_subnet02"
  }
# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "terra_igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Route Table Association for Public Subnet 01
resource "aws_route_table_association" "public_assoc_01" {
  subnet_id      = aws_subnet.terra_public_subnet01.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Association for Public Subnet 02
resource "aws_route_table_association" "public_assoc_02" {
  subnet_id      = aws_subnet.terra_public_subnet02.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_subnet" "terra_private_subnet02" {
  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "terra_private_subnet02"
  }
}

resource "aws_subnet" "terra_private_subnet01" {
  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "terra_private_subnet01"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


resource "aws_nat_gateway" "terra_nat" {
  subnet_id     = aws_subnet.terra_public_subnet01.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = "terra_nat"
  }

  depends_on = [aws_internet_gateway.terra_igw]
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra_nat.id
  }

  tags = {
    Name = "private_rt"
  }
}


resource "aws_route_table_association" "private_assoc_01" {
  subnet_id      = aws_subnet.terra_private_subnet01.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_02" {
  subnet_id      = aws_subnet.terra_private_subnet02.id
  route_table_id = aws_route_table.private_rt.id
}
                  
