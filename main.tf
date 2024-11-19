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

  metadata_options {
    http_tokens            = "required" # Use IMDSv2 (set to "optional" if you want IMDSv1 support as well)
    http_endpoint          = "enabled"  # Make sure the metadata service is accessible
    instance_metadata_tags = "enabled"
  }

  # Install Kubernetes via user_data
  user_data = file("script.sh")
}

# Output public IPs for SSH access
output "public_ips" {
  value = [for instance in aws_instance.k8s_nodes : instance.public_ip]
}