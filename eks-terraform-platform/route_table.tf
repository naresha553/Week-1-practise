# ========================================
# Public Route Table - Internet Gateway Access
# ========================================
# Routes all outbound traffic directly to IGW
# Associated with: public subnets
# ========================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-public-rt"
  }
}

# Route: 0.0.0.0/0 → Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnet 1 with public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate public subnet 2 with public route table
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ========================================
# Private Route Table - NAT Gateway Access
# ========================================
# Routes all outbound traffic through NAT Gateway
# Associated with: private subnets
# This is where the security magic happens!
# ========================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-private-rt-1a"
  }
}

# Route: 0.0.0.0/0 → NAT Gateway in AZ 1a
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnet 1 with private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# Second private route table for HA
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-private-rt-1b"
  }
}

# Route: 0.0.0.0/0 → NAT Gateway in AZ 1b
resource "aws_route" "private_nat_access_2" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

# Associate private subnet 2 with second private route table
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt_2.id
}
