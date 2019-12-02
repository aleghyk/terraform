provider "aws" {
    alias = "peer"
    region = "${var.monitoring-prod-region}"
    profile = "${var.aws-profile}"
}

resource "aws_vpc" "jenkins-vpc" {    
    cidr_block                        = "${lookup(var.jenkins-vpc-cidr, var.env)}"
    assign_generated_ipv6_cidr_block  = true
    enable_dns_hostnames              = true
    
    tags {
        "Name" = "jenkins-${var.env}-vpc"
    }
}

resource "aws_subnet" "jenkins-public-subnet" {
    vpc_id            = "${aws_vpc.jenkins-vpc.id}"
    cidr_block        = "${lookup(var.jenkins-pub-subnet-cidr, var.env)}"
    availability_zone = "${var.aws-availability-zone}"
    
    tags {
        "Name" = "jenkins-${var.env}-pub-net"
    }
}

resource "aws_internet_gateway" "jenkins-igw" {
    vpc_id = "${aws_vpc.jenkins-vpc.id}"
}

resource "aws_route_table" "jenkins-route-tbl" {
    vpc_id = "${aws_vpc.jenkins-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.jenkins-igw.id}"
    }

    route {
        cidr_block = "${var.monitoring-prod-vpc-cidr}"
        gateway_id = "${aws_vpc_peering_connection.monitoring-prod-vpc-peer.id}"
    }

    tags {
        Name = "jenkins-${var.env}-route-table"
    }
}

resource "aws_route_table_association" "public-assoc" {
    subnet_id = "${aws_subnet.jenkins-public-subnet.id}"
    route_table_id = "${aws_route_table.jenkins-route-tbl.id}"
}

resource "aws_vpc_peering_connection" "monitoring-prod-vpc-peer" {
    peer_vpc_id = "${var.monitoring-prod-vpc-id}"
    vpc_id = "${aws_vpc.jenkins-vpc.id}"
    peer_region ="${var.monitoring-prod-region}"
  
    tags {
        Name = "VPC Peering Jenkins and Monitoring Prod"
    }
}

resource "aws_vpc_peering_connection_accepter" "monitoring-peer-accepter" {
    provider                  = "aws.peer"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.monitoring-prod-vpc-peer.id}"
    auto_accept               = true
}

output "jenkins-public-subnet-id" {
  value = "${aws_subnet.jenkins-public-subnet.id}"
}

output "jenkins-vpc-id" {
  value = "${aws_vpc.jenkins-vpc.id}"
}