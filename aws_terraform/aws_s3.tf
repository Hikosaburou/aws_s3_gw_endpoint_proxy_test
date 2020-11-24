resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = data.aws_iam_policy_document.b_policy.json
}

data "aws_iam_policy_document" "b_policy" {
  statement {
    sid = "ALLOWONLYGWENDPOINT"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.b.arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"

      values = [
        aws_vpc_endpoint.s3.id
      ]
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.b.bucket
}