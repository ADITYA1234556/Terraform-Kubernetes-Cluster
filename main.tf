terraform {
  backend "s3" {
    bucket = "111-aditya-bucket"
    key    = "terraform/terraform.tfstate"
    region = "eu-west-2" # Replace with your desired AWS region
  }
}
provider "aws" {
  region = var.region
}

resource "aws_instance" "k8s_nodes" {
  count           = var.instance_count
  ami             = var.ami_id["ubuntu"]
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name        = "k8s-node-${count.index}"
    Environment = "Development"
  }

  # Install Kubernetes via user_data
  user_data = file("script.sh")
}

# Output public IPs for SSH access
output "public_ips" {
  value = [for instance in aws_instance.k8s_nodes : instance.public_ip]
}
