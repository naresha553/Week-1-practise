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

output "test_ec2_1_instance_id" {
  description = "Test EC2 Instance 1 Instance ID"
  value       = aws_instance.test_ec2_1.id
}

output "test_ec2_1_private_ip" {
  description = "Test EC2 Instance 1 Private IP"
  value       = aws_instance.test_ec2_1.private_ip
}

output "test_ec2_2_instance_id" {
  description = "Test EC2 Instance 2 Instance ID"
  value       = aws_instance.test_ec2_2.id
}

output "test_ec2_2_private_ip" {
  description = "Test EC2 Instance 2 Private IP"
  value       = aws_instance.test_ec2_2.private_ip
}

# ========================================
# Security Outputs
# ========================================

output "security_group_id" {
  description = "Security Group ID for worker nodes and pods"
  value       = aws_security_group.eks_sg.id
}

# ========================================
# Public & Private Security Groups
# ========================================

output "public_sg_id" {
  description = "Public Security Group ID - Use with EC2 instances that have public IPs"
  value       = aws_security_group.public_sg.id
}

output "public_sg_name" {
  description = "Public Security Group Name"
  value       = aws_security_group.public_sg.name
}

output "private_sg_id" {
  description = "Private Security Group ID - Use with EC2 instances in private subnets"
  value       = aws_security_group.private_sg.id
}

output "private_sg_name" {
  description = "Private Security Group Name"
  value       = aws_security_group.private_sg.name
}

# ========================================
# Bastion Host Outputs
# ========================================

output "bastion_instance_id" {
  description = "Bastion Instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion Public IP (Elastic IP)"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion Private IP"
  value       = aws_instance.bastion.private_ip
}

output "ssh_to_bastion" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_eip.bastion.public_ip}"
}

output "ssh_to_test_ec2_1_via_bastion" {
  description = "SSH to Test EC2 1 via Bastion (2-step)"
  value       = "ssh -i ./eks-key.pem -J ubuntu@${aws_eip.bastion.public_ip} ubuntu@${aws_instance.test_ec2_1.private_ip}"
}

output "ssh_to_test_ec2_2_via_bastion" {
  description = "SSH to Test EC2 2 via Bastion (2-step)"
  value       = "ssh -i ./eks-key.pem -J ubuntu@${aws_eip.bastion.public_ip} ubuntu@${aws_instance.test_ec2_2.private_ip}"
}

# ========================================
# EKS Cluster Outputs
# ========================================

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "EKS Cluster Kubernetes Version"
  value       = aws_eks_cluster.main.version
}

output "eks_node_group_status" {
  description = "EKS Node Group Status"
  value       = aws_eks_node_group.main.status
}

output "eks_node_group_id" {
  description = "EKS Node Group ID"
  value       = aws_eks_node_group.main.id
}

output "update_kubeconfig_command" {
  description = "Command to update kubeconfig for EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "kubectl_test_command" {
  description = "Command to test kubectl access to EKS cluster"
  value       = "kubectl get nodes"
}

output "kubectl_pods_command" {
  description = "Command to see all pods in the cluster"
  value       = "kubectl get pods --all-namespaces"
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

output "ssh_command_test_ec2_1" {
  description = "SSH command to connect to Test EC2 1 (via bastion/Systems Manager)"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_instance.test_ec2_1.private_ip}"
}

output "ssh_command_test_ec2_2" {
  description = "SSH command to connect to Test EC2 2 (via bastion/Systems Manager)"
  value       = "ssh -i ./eks-key.pem ubuntu@${aws_instance.test_ec2_2.private_ip}"
}

# ========================================
# Architecture Summary Output
# ========================================

output "architecture_summary" {
  description = "EKS Lab Infrastructure - Complete Setup"
  value = <<-EOT
    EKS Lab Infrastructure - Complete Setup
    =======================================
    
    MANAGED KUBERNETES CLUSTER:
      ├─ EKS Managed Kubernetes Cluster
      ├─ Version: 1.30
      ├─ Managed Nodes: 3 × t3.small
      ├─ Auto Scaling: 3-5 nodes (for blue/green deployment)
      └─ Use for: Production workloads, Kubernetes services
    
    STANDALONE TEST INSTANCES:
      ├─ test-ec2-1: t3.micro in private subnet 1a
      ├─ test-ec2-2: t3.micro in private subnet 1b
      ├─ NOT part of EKS cluster
      └─ Use for: Testing, debugging, standalone services
    
    NETWORK ARCHITECTURE:
      PUBLIC SUBNETS (10.0.1.0/24 & 10.0.3.0/24):
        ├─ Bastion Host (EC2) - Has Public IP
        ├─ NAT Gateways × 2 (HA across AZs)
        └─ Internet Gateway (IGW)
      
      PRIVATE SUBNETS (10.0.2.0/24 & 10.0.4.0/24):
        ├─ EKS Worker Nodes × 3 (NO public IP)
        ├─ Test EC2 Instances × 2 (NO public IP)
        ├─ Kubernetes Pods/Services
        └─ All outbound via NAT Gateway
    
    SECURITY:
      ✓ All instances in private subnets (no direct internet)
      ✓ Bastion in public subnet (your only SSH entry point)
      ✓ EKS pods accessed via services/load balancers
      ✓ Test instances for debugging/testing
      ✓ All outbound via NAT Gateway
    
    NEXT STEPS AFTER TERRAFORM APPLY:
      1. Update kubeconfig for kubectl:
         aws eks update-kubeconfig --region us-east-1 --name eks-lab-cluster
      
      2. Test kubectl:
         kubectl get nodes          (see 3 EKS nodes)
         kubectl get pods -A        (see system pods)
      
      3. Deploy sample webserver on EKS:
         kubectl create deployment nginx --image=nginx:latest
         kubectl expose deployment nginx --port=80 --type=LoadBalancer
      
      4. Access test EC2s via Bastion:
         Get command from: terraform output -raw ssh_to_test_ec2_1_via_bastion
      
      5. Blue/Green Deployment:
         Use kubectl to manage versions on EKS nodes
         Auto Scaling configured for 3-5 nodes
    
    RESOURCE BREAKDOWN:
      - EKS Cluster: 1 (managed)
      - EKS Managed Nodes: 3 × t3.small
      - Test EC2 Instances: 2 × t3.micro
      - Bastion Host: 1 × t3.micro
      - NAT Gateways: 2 (for HA)
      - Security Groups: 3 (bastion, public, private)
      - Key Pairs: 1
      - IAM Roles: 2 (EKS cluster + EKS nodes)
    
    ESTIMATED MONTHLY COSTS:
      - 3 × t3.small (EKS): ~$52
      - 3 × t3.micro (bastion + test): ~$22
      - 2 × NAT Gateway: ~$65
      - EKS Control Plane: ~$72
      - Total: ~$211/month if left running
      
    ⚠️  Remember to destroy resources when not in use!
    terraform destroy
  EOT
}

