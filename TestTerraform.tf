terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

//////////////
//S3 BUCKETS//
//////////////

//mfa delete: da abilitare a mano post terraform (serve owner+mfa)

resource "aws_s3_bucket" "example" {
  bucket = "terraform-test-bucket-dvlvanzi"

  tags = {
    Name  = "terraformtestbucket"
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}

//acl
resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}
//versioning + mfa delete
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

//LOGGING
resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id

  target_bucket = aws_s3_bucket.example.id
  target_prefix = "log/"
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

//ec2

resource "aws_instance" "app_server" {
  ami               = "ami-0568773882d492fc8"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"

  tags = {
    Name  = "TerraformTestingEc2"
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test.id
  instance_id = aws_instance.app_server.id
}


resource "aws_ebs_volume" "test" {
  availability_zone = "us-east-2a"
  size              = 1
}

