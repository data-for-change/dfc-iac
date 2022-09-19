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
