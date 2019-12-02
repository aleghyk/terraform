resource "aws_volume_attachment" "jenkins-data-ebs-attach" {
    device_name = "/dev/xvdb"
    volume_id = "${lookup(var.ec2-data-ebs-id, var.env)}"
    instance_id = "${aws_instance.jenkins-ec2.id}"
}

resource "aws_instance" "jenkins-ec2" {
    ami = "${var.aws-ec2-ami-id}"
    instance_type = "${lookup(var.aws-ec2-type, var.env)}"
    key_name = "${lookup(var.aws-key-name, var.env)}"
    associate_public_ip_address = "true"
    availability_zone = "${var.aws-availability-zone}"
    vpc_security_group_ids = ["${aws_security_group.jenkins-web-ssh-sg.id}", "${aws_security_group.jenkins-default-sg.id}"]
    subnet_id = "${var.jenkins-public-subnet-id}"

    tags {
        "Name" = "jenkins-ec2-${var.env}"
    }
}

resource "aws_eip" "jenkins-eip" {
    instance = "${aws_instance.jenkins-ec2.id}"
    vpc = true

    tags {
        "Name" = "jenkins-ec2-${var.env}-eip"
    }
}