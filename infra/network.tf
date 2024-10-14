# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.resource_name
  }
}

# Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  # Enable it if the subnet is public
  map_public_ip_on_launch = true

  tags = {
    Name = var.resource_name
  }
}

# Make the subnet public
resource "aws_internet_gateway" "my_vpc" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.resource_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.resource_name
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_vpc.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public.id
}


# AWS Net Flow
resource "aws_flow_log" "my_vpc" {
  iam_role_arn    = aws_iam_role.my_vpc.arn
  log_destination = aws_cloudwatch_log_group.my_vpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.my_vpc.id

  tags = {
    Name = var.resource_name
  }
}

resource "aws_cloudwatch_log_group" "my_vpc" {
  name              = "vpc-flow-log"
  retention_in_days = 365
}

data "aws_iam_policy_document" "my_vpc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "my_vpc" {
  name               = "vpc-flow-log"
  assume_role_policy = data.aws_iam_policy_document.my_vpc.json
}

data "aws_iam_policy_document" "my_vpc_s3" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/logs"
    ]
  }
}

resource "aws_iam_role_policy" "my_vpc" {
  name   = "vpc-flow-log"
  role   = aws_iam_role.my_vpc.id
  policy = data.aws_iam_policy_document.my_vpc_s3.json
}
