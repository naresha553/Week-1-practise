# ========================================
# Internet Gateway
# ========================================
# Provides internet connectivity to the VPC
# 
# Traffic Flow:
# Public Subnet → IGW → Internet
# Private Subnet → NAT Gateway → IGW → Internet
# ========================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-igw"
  }
}
