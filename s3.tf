
resource "aws_s3_bucket" "primary" {
  bucket = var.primary_bucket_name
}

resource "aws_s3_bucket_acl" "private_primary" {
  bucket = aws_s3_bucket.primary.id
  acl    = "private"
}


resource "aws_s3_bucket" "aux" {
  bucket = var.aux_bucket_name
}

resource "aws_s3_bucket_acl" "private_aux" {
  bucket = aws_s3_bucket.aux.id
  acl    = "private"
}