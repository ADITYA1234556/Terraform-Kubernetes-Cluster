terraform {
  backend "s3" {
    bucket = "111-aditya-bucket"
    key    = "terraform-KUBERNETES/terraform.tfstate"
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
  subnet_id       = element(var.subnet_ids, count.index % length(var.subnet_ids))
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
  user_data = file("${path.module}/script.sh")
#   user_data_hash = filemd5("${path.module}/script.sh")

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "k8s-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Output public IPs for SSH access
output "public_ips" {
  value = [for instance in aws_instance.k8s_nodes : instance.public_ip]
}