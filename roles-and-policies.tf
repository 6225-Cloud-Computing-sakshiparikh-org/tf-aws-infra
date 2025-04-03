resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy for EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.private_bucket.arn}",
          "${aws_s3_bucket.private_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Enhanced CloudWatch permissions
resource "aws_iam_policy" "cloudwatch_access_policy" {
  name        = "cloudwatch-access-policy"
  description = "Policy for EC2 to send metrics/logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

# SSM Parameter Store access
resource "aws_iam_policy" "ssm_access_policy" {
  name        = "ssm-access-policy"
  description = "Policy for EC2 to access SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/csye6225/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_access_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

# Add SSM permissions for CloudWatch agent
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Auto Scaling Service Role
resource "aws_iam_role" "asg_role" {
  name = "asg-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "autoscaling.amazonaws.com" }
    }]
  })
}

# Replace the incorrect policy attachment with the correct one
resource "aws_iam_role_policy_attachment" "asg_policy_attachment" {
  role       = aws_iam_role.asg_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# Add CloudWatch monitoring permissions for ASG
resource "aws_iam_role_policy_attachment" "asg_cloudwatch_attachment" {
  role       = aws_iam_role.asg_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
