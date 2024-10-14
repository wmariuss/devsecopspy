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

  tags = {
    Name = var.resource_name
  }
}


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
