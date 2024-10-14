# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = var.resource_name
  }
}

# IAM Policy for EC2 to access specific S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2-s3-access-policy"
  description = "Policy to allow EC2 instance access to S3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })

  tags = {
    Name = var.resource_name
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
