# ========================================
# Test EC2 Instances - For Testing/Debugging
# ========================================
# Standalone Ubuntu instances for testing
# These are NOT part of EKS cluster
# EKS has its own 3 managed nodes
# ========================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Test EC2 Instance 1 - Private Subnet 1a
resource "aws_instance" "test_ec2_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # No public IP - All traffic goes through NAT Gateway
  # Used for testing/debugging only
  associate_public_ip_address = false

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx docker.io curl wget
              systemctl start docker
              systemctl enable docker
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tags = {
    Name = "test-ec2-1"
    Role = "test"
  }
}

# Test EC2 Instance 2 - Private Subnet 1b
resource "aws_instance" "test_ec2_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # No public IP - traffic routed through NAT Gateway
  # Used for testing/debugging only
  associate_public_ip_address = false

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx docker.io curl wget
              systemctl start docker
              systemctl enable docker
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tags = {
    Name = "test-ec2-2"
    Role = "test"
  }
}
