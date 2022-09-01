terraform {
 provider "aws" {
  alias = "AWS Terraform testing"
  region  = "us-west-2"


  }
//buckets
  resource "aws_s3_bucket" "example" {
    bucket = "terraform_test_bucket"
    acl    = "private"
    versioning.mfa_delete = "true"
    versioning.enabled = "true"

    object_lock_configuration {
    object_lock_enabled = "Enabled"

    rule {
      default_retention {
        mode = "COMPLIANCE"
        days = 5
      }
    }
  }

    tags = {
      Name = "Terraform Test Bucket"
      Owner = "Vanzi"
      BU = "Cloud"
    }
  }

  resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
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
    ami           = "ami-830c94e3"
    instance_type = "t2.micro"

    tags = {
      Name = "TerraformTestingEc2"
      Owner = "Vanzi"
      BU = "Cloud"
    }
  }

  resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test.id
  instance_id = aws_instance.app_server.id
  }


  resource "aws_ebs_volume" "test" {
    availability_zone = "us-west-2"
    size              = 1
  }
}
