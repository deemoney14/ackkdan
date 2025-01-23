provider "aws" {
  region = "us-west-1"

}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "ackkdan" {
    bucket = "my-ackkdan-${random_string.bucket_suffix.result}"


    tags = {
      Name = "MyWorkingSite"
      Environment = "Dev"
    }
  
}
#Website hosting for s3
resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.ackkdan.id

    index_document {
      suffix = "index.html"
    }

    error_document {
      key = "error.html"
    }
  
}
# Public access
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.ackkdan.id

 block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  
}
#Allow world to read it

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.ackkdan.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.ackkdan.arn}/*"

        }]
    })
  
}

 #Upload website files (index.html, error.html, styles.css, and images)
resource "aws_s3_object" "website_files" {
  for_each = fileset("/home/sammy/containers/ackkdan_solutions/website", "**")

  bucket       = aws_s3_bucket.ackkdan.id
  key          = each.value
  source       = "/home/sammy/containers/ackkdan_solutions/website/${each.value}"
  content_type = lookup({
    "html"  = "text/html",
    "css"   = "text/css",
    "js"    = "application/javascript",
    "png"   = "image/png",
    "jpg"   = "image/jpeg",
    "jpeg"  = "image/jpeg",
    "gif"   = "image/gif"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
