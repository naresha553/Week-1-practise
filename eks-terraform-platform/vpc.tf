# ========================================
# EKS Lab Architecture - Week 1
# ========================================
# PUBLIC SUBNET (10.0.1.0/24)
#   └─ Internet Gateway
#   └─ NAT Gateway (for private subnet outbound)
#   └─ Load Balancer (future)
#
# PRIVATE SUBNET (10.0.2.0/24)
#   └─ Worker Nodes (EC2 instances)
#   └─ Pods (Kubernetes workloads)
#   └─ Routes internet traffic through NAT Gateway
#
# SECURITY MODEL:
# Pods → NAT Gateway → Internet
# - Pods pull container images from registries
# - Pods can call external APIs
# - No direct exposure to internet (inbound protection)
# ========================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-vpc"
  }
}

# Public Subnet - For NAT Gateway and Load Balancer
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "eks-public-subnet"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/type"                  = "public"
  }
}

# Private Subnet - For Worker Nodes and Pods
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                                    = "eks-private-subnet"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/type"                  = "private"
  }
}

# Additional Public Subnet for HA (optional)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "eks-public-subnet-2"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/type"                  = "public"
  }
}

# Additional Private Subnet for HA (optional)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name                                    = "eks-private-subnet-2"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/type"                  = "private"
  }
}
