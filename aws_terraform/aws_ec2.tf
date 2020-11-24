resource "aws_key_pair" "auth" {
  key_name   = "${var.pj-prefix}-web"
  public_key = file(var.public_key_path)
}

### Amazon Linux 2の最新版AMIを取得する
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

### CentOS 7 の最新版AMIを取得する
data aws_ami centos7_ami {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

### Proxy Instance
data "template_file" "proxy_userdata" {
  template = "${file("${path.module}/proxy_userdata.sh")}"
  vars     = {}
}

resource "aws_instance" "proxy" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.auth.id
  subnet_id                   = aws_subnet.gateway_public-a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.s3_allow.name
  user_data                   = data.template_file.proxy_userdata.rendered

  vpc_security_group_ids = [
    aws_security_group.gateway_ssh.id,
    aws_security_group.gateway_proxy.id
  ]

  tags = {
    Name = "${var.pj-prefix}-proxy"
  }
}

resource "aws_eip" "proxy" {
  instance = aws_instance.proxy.id
  vpc      = true
}

### Client Instance
data "template_file" "client_userdata" {
  template = "${file("${path.module}/client_userdata.sh")}"
  vars = {
    proxy_dns = aws_instance.proxy.private_dns
  }
}

resource "aws_instance" "client" {
  ami                         = data.aws_ssm_parameter.amzn2_ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.auth.id
  subnet_id                   = aws_subnet.client_public-a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.s3_allow.name
  user_data                   = data.template_file.client_userdata.rendered

  vpc_security_group_ids = [
    aws_security_group.client_ssh.id
  ]

  tags = {
    Name = "${var.pj-prefix}-client"
  }
}

resource "aws_eip" "client" {
  instance = aws_instance.client.id
  vpc      = true
}

# Output Param
output "ec2_public-dns" {
  value = {
    "proxy_dns"          = aws_eip.proxy.public_dns
    "proxy_internal_dns" = aws_instance.proxy.private_dns
    "client_dns"         = aws_eip.client.public_dns
  }
}