variable "pj-prefix" {
  description = "your project name"
  type        = string

  default = "s3-gw"
}

variable "gateway_vpc_cidr" {
  description = "CIDR Block for VPC 'gateway_vpc'"
  type        = string

  default = "10.1.0.0/16"
}

variable "gateway_vpc_public-a_cidr" {
  description = "CIDR Block for subnet 'gateway-public-a'"
  type        = string

  default = "10.1.1.0/24"
}

variable "client_vpc_cidr" {
  description = "CIDR Block for VPC 'client_vpc'"
  type        = string

  default = "10.2.0.0/16"
}

variable "client_vpc_public-a_cidr" {
  description = "CIDR Block for subnet 'client-public-a'"
  type        = string

  default = "10.2.1.0/24"
}

variable "my_ip" {
  description = "Your IP address"
  type        = string
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
  type        = string
}

variable "bucket_name" {
  description = "Bucket name"
  type        = string
}