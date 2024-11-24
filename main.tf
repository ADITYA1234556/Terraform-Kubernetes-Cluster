terraform {
  backend "s3" {
    bucket = "111-aditya-bucket"
    key    = "terraform-KUBERNETES/terraform.tfstate"
    region = "eu-west-2" # Replace with your desired AWS region
  }
}

terraform {
  required_providers {
    localos = {
      source  = "fireflycons/localos"
      version = "0.1.2"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "tf:stackid" = "kubeadm-cluster"
    }
  }
}

resource "aws_instance" "k8s_nodes" {
  count           = var.instance_count
  ami             = var.ami_id["ubuntu"]
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name        = "k8s-node-${count.index}"
    Environment = "Development"
  }

  metadata_options {
    http_tokens            = "required" # Use IMDSv2 (set to "optional" if you want IMDSv1 support as well)
    http_endpoint          = "enabled"  # Make sure the metadata service is accessible
    instance_metadata_tags = "enabled"
  }

  lifecycle {
    ignore_changes = [tags, security_groups, root_block_device, vpc_security_group_ids,]
  }

  # Install Kubernetes via user_data
#   user_data = file("script.sh")
  user_data = file("${path.module}/script.sh")
#   user_data_hash = filemd5("${path.module}/script.sh")

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "k8s-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

