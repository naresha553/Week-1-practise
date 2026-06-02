# ========================================
# Bastion Host - Jump Server
# ========================================
# Bastion host in PUBLIC subnet for accessing
# private worker nodes via SSH tunneling
# ========================================

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "eks-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  # ✓ SSH from your laptop/allowed CIDR
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "SSH access from your laptop"
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
    Name = "eks-bastion-sg"
  }
}

# Allow bastion to SSH to worker nodes (private SG)
resource "aws_security_group_rule" "bastion_to_workers" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.private_sg.id
  description              = "SSH from bastion to workers"
}

# Bastion EC2 Instance - Public Subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  # Install SSH client and common tools
  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openssh-client aws-cli
              EOF
  )

  tags = {
    Name = "eks-bastion"
    Role = "bastion"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Elastic IP for Bastion (static public IP)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "eks-bastion-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}
