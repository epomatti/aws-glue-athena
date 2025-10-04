resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-glue-${var.aws_region}"

  force_destroy = true

  tags = {
    Name = "Sandbox Bucket"
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
