//general
variable "region" {}
variable "access_key" {}
variable "secret_key" {}

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
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

//////////////
//S3 BUCKETS//
//////////////

//mfa delete: da abilitare a mano post terraform (serve owner+mfa)

//da fare:
//encryption no kms

locals {
  bucket_settings = {
    "terraform-test-bucket-dvlvanzi1"  = { acl_value = "private", bucket_versioning = "Enabled", target_log_bucket = "terraform-test-bucket-dvlvanzi1" },
    "terraform-test-bucket-dvlvanzi2"   = { acl_value = "authenticated-read", bucket_versioning = "Enabled", target_log_bucket = "terraform-test-bucket-dvlvanzi2" },
    "terraform-test-bucket-dvlvanzi3" = { acl_value = "aws-exec-read", bucket_versioning = "Enabled", target_log_bucket = "terraform-test-bucket-dvlvanzi3" },
    "terraform-test-bucket-dvlvanzi4"    = { acl_value =  "public-read", bucket_versioning = "Enabled", target_log_bucket = "terraform-test-bucket-dvlvanzi4" }
  }
}

/*
resource "aws_s3_bucket" "vanzi" {
  for_each      = "${var.locals.bucket_settings}"
  bucket = each.key
  tags = {
    Name  = each.key
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}
*/
resource "aws_s3_bucket" "vanzi" {
  for_each      = local.bucket_settings
  bucket = each.key
  tags = {
    Name  = each.key
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}

//acl
resource "aws_s3_bucket_acl" "vanzi_bucket_acl" {
  for_each      = local.bucket_settings
  bucket = each.key
  //acl    = "private"
  acl    = each.value.acl_value
}
//versioning 
resource "aws_s3_bucket_versioning" "versioning_vanzi" {
  for_each      = local.bucket_settings
  bucket = each.key
  versioning_configuration {
    //status = "Enabled"
    status = each.value.bucket_versioning
  }
}

//LOGGING
resource "aws_s3_bucket_logging" "vanzi" {
  for_each      = local.bucket_settings
  bucket = each.key
  target_bucket = each.value.target_log_bucket
  target_prefix = "log/"
}
/*
//encryption KMS
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}
*/

resource "aws_s3_bucket_server_side_encryption_configuration" "vanzi" {
  for_each      = local.bucket_settings
  bucket = each.key
  rule {
    apply_server_side_encryption_by_default {
      //for kms key
      //kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm = "AES256"
    }
  }
}

/////////////
/////EC2/////
/////////////

//da fare:

//no public ip
//variabili!




//security group
resource "aws_security_group" "tf_vanzi_sg" {
  name = "tf_vanzi_sg"

  #Incoming traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #replace it with your ip address
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
//iam role
resource "aws_iam_role" "tf_vanzi_role" {
  name = "tf_vanzi_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name  = "TerraformTestingEc2"
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}
//profile
resource "aws_iam_instance_profile" "tf_vanzi_profile" {
  name = "tf_vanzi_profile"
  role = aws_iam_role.tf_vanzi_role.name
}
//permissions
resource "aws_iam_role_policy" "tf_vanzi_policy" {
  name = "tf_vanzi_policy"
  role = aws_iam_role.tf_vanzi_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
//ssh key
resource "aws_key_pair" "tf_vanzi_key" {
  key_name   = "tf_vanzi_key"
  public_key = file("/home/ec2-user/.ssh/tf_vanzi_key.pub")
}

resource "aws_instance" "app_server" {
  ami                         = "ami-0568773882d492fc8"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-2a"
  associate_public_ip_address = "false"
  iam_instance_profile        = aws_iam_instance_profile.tf_vanzi_profile.name
  security_groups             = ["tf_vanzi_sg"]
  key_name                    = aws_key_pair.tf_vanzi_key.key_name

  # root disk
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name  = "TerraformTestingEc2"
    Owner = "Vanzi"
    BU    = "Cloud"
  }
}

resource "aws_ebs_encryption_by_default" "vanzi" {
  enabled = true
}

/*
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test.id
  instance_id = aws_instance.app_server.id
}


resource "aws_ebs_volume" "test" {
  availability_zone = "us-east-2a"
  size              = 1
}

resource "aws_ebs_encryption_by_default" "vanzi" {
  enabled = true
}
*/
