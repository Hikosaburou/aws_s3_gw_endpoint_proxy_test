# Gateway VPC
resource "aws_vpc" "gateway_vpc" {
  cidr_block           = var.gateway_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pj-prefix}-gateway-vpc"
  }
}

resource "aws_internet_gateway" "gateway_igw" {
  vpc_id = aws_vpc.gateway_vpc.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.gateway_vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = [aws_route_table.gateway_public.id]

  tags = {
    Name = "${var.pj-prefix}-endpoint"
  }
}

resource "aws_subnet" "gateway_public-a" {
  vpc_id            = aws_vpc.gateway_vpc.id
  cidr_block        = var.gateway_vpc_public-a_cidr
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.pj-prefix}-gateway-public-a"
  }
}

resource "aws_route_table" "gateway_public" {
  vpc_id = aws_vpc.gateway_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway_igw.id
  }

  route {
    cidr_block = var.client_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }

  tags = {
    Name = "${var.pj-prefix}-gateway-public"
  }
}

resource "aws_route_table_association" "gateway_public-a" {
  subnet_id      = aws_subnet.gateway_public-a.id
  route_table_id = aws_route_table.gateway_public.id
}


## Client VPC
resource "aws_vpc" "client_vpc" {
  cidr_block           = var.client_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.pj-prefix}-client-vpc"
  }
}

resource "aws_internet_gateway" "client_igw" {
  vpc_id = aws_vpc.client_vpc.id
}

resource "aws_subnet" "client_public-a" {
  vpc_id            = aws_vpc.client_vpc.id
  cidr_block        = var.client_vpc_public-a_cidr
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.pj-prefix}-client-public-a"
  }
}

resource "aws_route_table" "client_public" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.client_igw.id
  }

  route {
    cidr_block = var.gateway_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }

  tags = {
    Name = "${var.pj-prefix}-client-public"
  }
}

resource "aws_route_table_association" "client_public-a" {
  subnet_id      = aws_subnet.client_public-a.id
  route_table_id = aws_route_table.client_public.id
}


### VPC Peering

resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id = aws_vpc.gateway_vpc.id
  vpc_id      = aws_vpc.client_vpc.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}