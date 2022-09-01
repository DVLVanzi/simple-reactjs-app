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


//buckets
//manca logging
//versioning
//encryption
//mfa delete
//object lock
resource "aws_s3_bucket" "example" {
  bucket = "terraform-test-bucket-dvlvanzi"
  
  tags = {
    Name  = "terraformtestbucket"
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}


resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

//ec2

resource "aws_instance" "app_server" {
  ami           = "ami-0568773882d492fc8"
  instance_type = "t2.micro"
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

