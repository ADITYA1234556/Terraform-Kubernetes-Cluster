# Output public IPs for SSH access
output "public_ips" {
  value = [for instance in aws_instance.k8s_nodes : instance.public_ip]
}

