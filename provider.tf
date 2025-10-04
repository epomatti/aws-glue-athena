provider "aws" {
  region = var.aws_region

  ignore_tags {
    key_prefixes = ["QSConfigId"]
  }
}
