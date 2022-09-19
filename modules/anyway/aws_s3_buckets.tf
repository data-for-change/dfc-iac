locals {
    bucket_names = {
        "dfc-anyway" = {}
        "dfc-anyway-full-db-dumps" = {}
        "dfc-anyway.co.il" = {}
        "dfc-anyway-cbs" = {}
        "dfc-anyway-partial-db-dumps" = {}
    }
}

resource "aws_s3_bucket" "bucket" {
    for_each = local.bucket_names
    bucket = each.key
}

resource "aws_iam_user" "db_dumps_writer" {
    name = "anyway-db-dumps-writer"
}

resource "null_resource" "aws_db_dumps_writer_keys_vault" {
    provisioner "local-exec" {
        command = "python3 vault/write_aws_access_keys.py ${aws_iam_user.db_dumps_writer.name} projects/anyway/prod/aws_db_dumps_writer_user"
    }
}

resource "aws_iam_user_policy" "db_dumps_writer" {
    name = "anyway-db-dumps-write"
    user = aws_iam_user.db_dumps_writer.name
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "statement1",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:HeadBucket",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-full-db-dumps"].id}",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-full-db-dumps"].id}/*",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user" "db_dumps_reader" {
    name = "anyway-db-dumps-reader"
}

resource "null_resource" "aws_db_dumps_reader_keys_vault" {
    provisioner "local-exec" {
        command = "python3 vault/write_aws_access_keys.py ${aws_iam_user.db_dumps_reader.name} projects/anyway/prod/aws_db_dumps_reader_user"
    }
}

resource "aws_iam_user_policy" "db_dumps_reader" {
    name = "anyway-db-dumps-reader"
    user = aws_iam_user.db_dumps_reader.name
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "statement1",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:HeadBucket",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:HeadObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-full-db-dumps"].id}",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-full-db-dumps"].id}/*",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user" "partial_db_dumps_reader" {
    name = "anyway-partial-db-dumps-reader"
}

resource "null_resource" "aws_partial_db_dumps_reader_keys_vault" {
    triggers = {
        version = 2
    }
    provisioner "local-exec" {
        command = "python3 vault/write_aws_access_keys.py ${aws_iam_user.partial_db_dumps_reader.name} projects/anyway/prod/aws_partial_db_dumps_reader_user"
    }
}

resource "aws_iam_user_policy" "partial_db_dumps_reader" {
    name = "anyway-partial-db-dumps-reader"
    user = aws_iam_user.partial_db_dumps_reader.name
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "statement1",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:HeadBucket",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:HeadObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}",
                "arn:aws:s3:::${aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id}/*"
            ]
        }
    ]
}
EOF
}
