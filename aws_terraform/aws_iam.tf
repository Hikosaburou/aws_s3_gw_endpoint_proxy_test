resource "aws_iam_role" "s3_allow" {
  name = "${var.pj-prefix}-s3-allow"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_allow" {
  name = "test_policy"
  role = aws_iam_role.s3_allow.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "s3_allow" {
  name = "${var.pj-prefix}-s3-allow"
  role = aws_iam_role.s3_allow.name
}