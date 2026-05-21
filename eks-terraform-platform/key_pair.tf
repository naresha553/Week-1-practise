resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "eks-deployer-key"
  public_key = tls_private_key.main.public_key_openssh
}
