resource "aws_instance" "JH1" {
    ami = "ami-0cc0a36f626a4fdf5"
    instance_type = "t2.micro"
    subnet_id = "subnet-eeebf1a3"
    vpc_security_group_ids = ["sg-042762992a5670259"]
    key_name = "JH"
    tags = {
      Name = "JH1"
    }
}
