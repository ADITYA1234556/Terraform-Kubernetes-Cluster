#GET THE PUBLIC OF IP OF THE CLOUDSHELL SERVER
data "localos_public_ip" "cloudshell_ip" {}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
  filter {
    name   = "availability-zone"
    values = [
      "${var.region}a",
      "${var.region}b",
      "${var.region}c"
    ]
  }
}

data "aws_security_group" "allconnect" {
  filter {
    name   = "group-id"
    values = ["sg-00c8b561dc6b524c6"]
  }
}