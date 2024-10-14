# Create VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.my_vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_vpc.my_vpc.main_route_table_id]

  tags = {
    Name = var.resource_name
  }
}
