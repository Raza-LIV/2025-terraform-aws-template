resource "aws_s3_bucket" "this" {
  bucket = "${var.env}-${var.bucket_name}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }

  tags = {
    Environment = var.env
    Name        = "${var.env}-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read_policy" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.public_read_policy.json
}
