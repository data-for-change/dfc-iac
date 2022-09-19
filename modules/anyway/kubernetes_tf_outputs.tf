output "kubernetes_tf_outputs" {
  value = {
    anyway_full_db_dumps_bucket = aws_s3_bucket.bucket["dfc-anyway-full-db-dumps"].id
    anyway_partial_db_dumps_bucket = aws_s3_bucket.bucket["dfc-anyway-partial-db-dumps"].id
  }
}
