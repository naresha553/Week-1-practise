# ========================================
# EC2 Instances - EKS Worker Nodes
# ========================================
# These instances are placed in PRIVATE subnets
# Benefits:
# ✓ No direct internet access (inbound blocked)
# ✓ Outbound through NAT Gateway only
# ✓ More secure for production workloads
# ✓ Pods can still pull images via NAT
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

# Worker Node 1 - Private Subnet 1a
resource "aws_instance" "worker_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # CRITICAL: No public IP assignment
  # All internet traffic goes through NAT Gateway
  associate_public_ip_address = false

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx docker.io
              systemctl start docker
              systemctl enable docker
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tags = {
    Name = "eks-worker-1"
    Role = "worker"
  }
}

# Worker Node 2 - Private Subnet 1b (for HA)
resource "aws_instance" "worker_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # No public IP - traffic routed through NAT Gateway
  associate_public_ip_address = false

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx docker.io
              systemctl start docker
              systemctl enable docker
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tags = {
    Name = "eks-worker-2"
    Role = "worker"
  }
}
