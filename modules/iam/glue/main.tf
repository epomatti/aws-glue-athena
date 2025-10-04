resource "aws_iam_role" "glue" {
  name = "GlueRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "AWSGlueServiceRole" {
  name = "AWSGlueServiceRole"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  name = "AmazonS3FullAccess"
}

data "aws_iam_policy" "AwsGlueConsoleFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

data "aws_iam_policy" "AmazonRDSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AWSGlueServiceRole.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AwsGlueConsoleFullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AwsGlueConsoleFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonRDSFullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = data.aws_iam_policy.AmazonRDSFullAccess.arn
}
