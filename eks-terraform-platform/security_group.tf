# ========================================
# Security Groups - Public & Private
# ========================================
# Modular security groups for EKS setup
# Public SG: For instances with public IPs
# Private SG: For instances in private subnets
# ========================================

# ========================================
# Public Security Group
# ========================================
# Use with EC2 instances that have public IP
resource "aws_security_group" "public_sg" {
  name        = "eks-public-sg"
  description = "Security group for public-facing resources"
  vpc_id      = aws_vpc.main.id

  # ✓ SSH from specified CIDR (default: 0.0.0.0/0 for lab)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "SSH access"
  }

  # ✓ HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # ✓ HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # ✓ All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "eks-public-sg"
  }
}

# ========================================
# Private Security Group
# ========================================
# Use with EC2 instances in private subnets
resource "aws_security_group" "private_sg" {
  name        = "eks-private-sg"
  description = "Security group for private resources"
  vpc_id      = aws_vpc.main.id

  # ✓ SSH only from Public SG
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    description     = "SSH from public SG"
  }

  # ✓ Pod-to-Pod communication (VPC CIDR)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Pod-to-Pod communication"
  }

  # ✓ All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "eks-private-sg"
  }
}

# ========================================
# Keep existing eks_sg for reference
# (Can remove after updating ec2.tf)
# ========================================
resource "aws_security_group" "eks_sg" {
  name        = "eks-security-group"
  description = "Security group for EKS worker nodes and pods"
  vpc_id      = aws_vpc.main.id

  # ✓ SSH access from anywhere (LAB ONLY - restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH - LAB ONLY"
  }

  # ✓ HTTP from Load Balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from LB"
  }

  # ✓ HTTPS from Load Balancer
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from LB"
  }

  # ✓ Pod-to-Pod communication (VPC CIDR)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Pod-to-Pod communication"
  }

  # ✓ All outbound traffic (NAT to internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound (via NAT)"
  }

  tags = {
    Name = "eks-security-group"
  }
}
