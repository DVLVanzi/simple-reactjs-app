terraform {
 provider "aws" {
  alias = "AWS Terraform testing"
  region  = "us-west-2"


  }
//buckets
  resource "terraform_test_bucket" "b" {
    bucket = "terraform_test_bucket"
    acl    = "private"
    tags = {
      Name = "Terraform Test Bucket"
      Owner = "Vanzi"
      BU = "Cloud"
    }
  }

//ec2

  resource "terraform_test_ec2" "app_server" {
    ami           = "ami-830c94e3"
    instance_type = "t2.micro"

    tags = {
      Name = "TerraformTestingEc2"
      Owner = "Vanzi"
      BU = "Cloud"
    }
  }

  resource "terraform_test_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = terraform_test_ebs.test.id
  instance_id = terraform_test_ec2.app_server.id
  }


  resource "terraform_test_ebs" "test" {
    availability_zone = "us-west-2"
    size              = 1
  }
}
