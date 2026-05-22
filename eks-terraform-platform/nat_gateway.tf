# ========================================
# NAT Gateway - Enables Private Subnet Outbound
# ========================================
# The NAT Gateway allows pods in the private subnet to:
# ✓ Pull container images from Docker Hub, ECR, etc.
# ✓ Call external APIs
# ✓ Access package managers (pip, npm, apt, etc.)
#
# Traffic Flow:
# Private Subnet → NAT Gateway → Internet Gateway → Internet
# ========================================

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway in public subnet (AZ 1a)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "eks-nat-gateway-1a"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Elastic IP for second NAT Gateway (HA)
resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip-2"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Second NAT Gateway in public subnet (AZ 1b) for High Availability
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "eks-nat-gateway-1b"
  }

  depends_on = [aws_internet_gateway.igw]
}
