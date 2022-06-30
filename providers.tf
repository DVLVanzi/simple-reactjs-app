provider "aws" {
  alias = "AWS CloudLab X22"
  region  = "us-west-2"

  # AWS Cloud account access keys
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"
  acl    = "public-read"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "" {
  bucket = "my-tf-test-bucket2"
  acl    = "public-read"
  tags = {
    Name        = "My bucket2"
    Environment = "Test"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}