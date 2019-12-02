variable "aws-ec2-type" {
    description = "EC2 instance type for Dev and prod"
    type = "map"
    default = {
        "dev"           = "t2.nano"
        "production"    = "t2.medium"
    }
}