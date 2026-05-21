output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "ec2_instance_id" {
  value = aws_instance.web.id
}

output "ec2_private_ip" {
  value = aws_instance.web.private_ip
}

output "security_group_id" {
  value = aws_security_group.eks_sg.id
}

output "ssh_private_key" {
  description = "SSH Private Key (TEST ONLY - Do not use in production)"
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}

output "key_pair_name" {
  value = aws_key_pair.deployer.key_name
}

output "ssh_command" {
  description = "SSH command to connect to EC2 instance (requires bastion/SSM)"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_instance.web.private_ip}"
}

output "key_file_path" {
  description = "Path to SSH private key file"
  value       = local_file.ssh_key.filename
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_eip" {
  description = "Elastic IP address of NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}
