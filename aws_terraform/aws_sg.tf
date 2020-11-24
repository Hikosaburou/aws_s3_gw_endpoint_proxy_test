# セキュリティグループの書き方は2通り？
# 1. aws_security_groupの中に直接記述
# 2. aws_security_group_rule を作成して、その中でSGを指定 (推奨)
resource "aws_security_group" "gateway_ssh" {
  name        = "${var.pj-prefix}-gateway-ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.gateway_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj-prefix}-gateway-ssh"
  }
}

resource "aws_security_group" "gateway_proxy" {
  name        = "${var.pj-prefix}-proxy"
  description = "Allow Proxy(Squid) Access"
  vpc_id      = aws_vpc.gateway_vpc.id

  # Squid default port
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [var.client_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj-prefix}-web"
  }
}

resource "aws_security_group" "client_ssh" {
  name        = "${var.pj-prefix}-client-ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.client_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.pj-prefix}-client-ssh"
  }
}