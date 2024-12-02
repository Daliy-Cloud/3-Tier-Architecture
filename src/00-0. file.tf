resource "random_string" "file_random" {
  length           = 3
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

resource "aws_s3_bucket" "app" {
  bucket = "app-${random_string.file_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "pyc" {
  bucket = aws_s3_bucket.app.id
  key    = "/app.pyc"
  source = "./src/image/app.pyc"
  etag   = filemd5("./src/image/app.pyc")
}

resource "aws_s3_object" "Docker" {
  bucket = aws_s3_bucket.app.id
  key    = "/Dockerfile"
  source = "./src/image/Dockerfile"
  etag   = filemd5("./src/image/Dockerfile")
}