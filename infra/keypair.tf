resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = var.resource_name
  public_key = tls_private_key.ec2.public_key_openssh

  tags = {
    Name = var.resource_name
  }
}

resource "local_sensitive_file" "ec2" {
  content  = tls_private_key.ec2.private_key_pem
  filename = "${path.cwd}/keypair.pem"
}
