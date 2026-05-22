# ========================================
# Security Group - EKS Network Policies
# ========================================
# Controls inbound/outbound traffic for
# worker nodes and pods
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
