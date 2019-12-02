terraform {
  backend "s3" {
  }
}

provider "aws" {
    region = "${var.aws-region}"
    profile = "${var.aws-profile}"
}

data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
    source = "vpc"
    env = "${var.env}"
    aws-availability-zone = "${data.aws_availability_zones.available.names[0]}"
    monitoring-prod-vpc-id = "${var.monitoring-prod-vpc-id}"
    monitoring-prod-region = "${var.monitoring-prod-region}"
    monitoring-prod-vpc-cidr = "${var.monitoring-prod-vpc-cidr}"
    aws-profile = "${var.aws-profile}"
}

module "ec2" {
    source = "ec2"
    env = "${var.env}"
    aws-availability-zone = "${data.aws_availability_zones.available.names[0]}"
    jenkins-public-subnet-id = "${module.vpc.jenkins-public-subnet-id}"
    jenkins-vpc-id = "${module.vpc.jenkins-vpc-id}"
}