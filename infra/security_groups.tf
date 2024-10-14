resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.my_vpc.id
  description = "Custom security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.78.48.238/32"] # Replace with your IP
    description = "Open ssh port for a specific public IP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open HTTPS port to all"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open all ports"
  }

  tags = {
    Name = var.resource_name
  }
}
