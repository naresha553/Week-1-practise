resource "local_file" "ssh_key" {
  filename        = "${path.module}/eks-key.pem"
  content         = tls_private_key.main.private_key_pem
  file_permission = "0600"
}
