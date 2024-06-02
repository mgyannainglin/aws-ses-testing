variable "email" {
  default = "yan.nainglin@outlook.com"
}
variable "smtp_username" {
  default = "smtp_ses"
}
variable "ses_sender" {
  default = "ses_sender"
}


variable "vpc_id" {
  default = "vpc-8ae1bbed"
}

variable "ses_svc_ep_name" {
  default = "com.amazonaws.ap-southeast-1.email-smtp"
}
variable "ses_vpc_ep_type" {
  default = "Interface"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnet" {
  default = "10.0.10.0/24"
}
variable "s3_bucket" {
  default = "tf-state-test-yan"
}
variable "default_rg" {
  default = "ap-southeast-1"
}