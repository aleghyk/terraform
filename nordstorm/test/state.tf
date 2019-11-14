data "terraform_remote_state" "remote-state" {
  backend = "s3"
  config {
    bucket     = "Nordtest"
    key        = "/terraformstate"
    region     = "${var.aws_region}"
  }
}