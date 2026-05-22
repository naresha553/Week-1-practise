# ========================================
# VPC Infrastructure Outputs
# ========================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.main.cidr_block
}

# ========================================
# Public Subnet Outputs
# ========================================

output "public_subnet_id" {
  description = "Public Subnet ID (1a) - For NAT and LB"
  value       = aws_subnet.public.id
}

output "public_subnet_id_2" {
  description = "Public Subnet ID (1b) - For HA"
  value       = aws_subnet.public_2.id
}

output "public_subnet_cidr" {
  description = "Public Subnet CIDR (1a)"
  value       = aws_subnet.public.cidr_block
}

# ========================================
# Private Subnet Outputs (Worker Nodes)
# ========================================

output "private_subnet_id" {
  description = "Private Subnet ID (1a) - For Worker Nodes"
  value       = aws_subnet.private.id
}

output "private_subnet_id_2" {
  description = "Private Subnet ID (1b) - For Worker Nodes HA"
  value       = aws_subnet.private_2.id
}

output "private_subnet_cidr" {
  description = "Private Subnet CIDR (1a)"
  value       = aws_subnet.private.cidr_block
}

# ========================================
# NAT Gateway Outputs
# ========================================

output "nat_gateway_id" {
  description = "NAT Gateway ID (AZ 1a) - Provides outbound internet access for pods"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_eip" {
  description = "NAT Gateway Public IP (AZ 1a) - This is the source IP for all pod outbound traffic"
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_id_2" {
  description = "NAT Gateway ID (AZ 1b) - For HA"
  value       = aws_nat_gateway.nat_2.id
}

output "nat_gateway_eip_2" {
  description = "NAT Gateway Public IP (AZ 1b)"
  value       = aws_eip.nat_2.public_ip
}

# ========================================
# Worker Nodes Outputs
# ========================================

output "worker_1_instance_id" {
  description = "Worker Node 1 Instance ID"
  value       = aws_instance.worker_1.id
}

output "worker_1_private_ip" {
  description = "Worker Node 1 Private IP (no public IP)"
  value       = aws_instance.worker_1.private_ip
}

output "worker_2_instance_id" {
  description = "Worker Node 2 Instance ID"
  value       = aws_instance.worker_2.id
}

output "worker_2_private_ip" {
  description = "Worker Node 2 Private IP (no public IP)"
  value       = aws_instance.worker_2.private_ip
}

# ========================================
# Security Outputs
# ========================================

output "security_group_id" {
  description = "Security Group ID for worker nodes and pods"
  value       = aws_security_group.eks_sg.id
}

output "ssh_private_key" {
  description = "SSH Private Key (TEST/LAB ONLY - Do not use in production)"
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}

output "key_pair_name" {
  description = "EC2 Key Pair Name for SSH access"
  value       = aws_key_pair.deployer.key_name
}

output "key_file_path" {
  description = "Path to SSH private key file"
  value       = local_file.ssh_key.filename
}

output "ssh_command_worker_1" {
  description = "SSH command to connect to Worker Node 1 (via bastion/Systems Manager)"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_instance.worker_1.private_ip}"
}

output "ssh_command_worker_2" {
  description = "SSH command to connect to Worker Node 2 (via bastion/Systems Manager)"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_instance.worker_2.private_ip}"
}

# ========================================
# Architecture Summary Output
# ========================================

output "architecture_summary" {
  description = "EKS Lab Architecture Summary"
  value = <<-EOT
    EKS Lab Infrastructure - Security Design Pattern
    ================================================
    
    PUBLIC SUBNET (10.0.1.0/24 & 10.0.3.0/24):
      └─ NAT Gateways × 2 (HA across AZs)
      └─ Internet Gateway (IGW)
      └─ Future: Load Balancer
    
    PRIVATE SUBNETS (10.0.2.0/24 & 10.0.4.0/24):
      └─ Worker Nodes (EC2 instances) × 2
      └─ Kubernetes Pods
      └─ NO direct internet access (blocked)
    
    TRAFFIC FLOW:
      Pods → NAT Gateway → IGW → Internet
    
    WHY PRIVATE?
      ✓ Security: Pods can't be accessed directly from internet
      ✓ Outbound Only: Pods can pull images, call APIs
      ✓ Application Servers: Protected from direct attacks
      ✓ Still accessible via Load Balancer for users
    
    ACCESS TO PODS:
      Users → Load Balancer (Public) → Pod (Private via NAT)
  EOT
}

