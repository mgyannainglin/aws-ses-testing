terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {

}

terraform {
  backend "s3" {
    bucket = "tf-state-test-yan"
    key    = "ses_test.tfstate"
    shared_credentials_files = [ "~/.aws/credentials" ]
    encrypt = true
    region = "ap-southeast-1"
  }
}

#Creating vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "aws-ses-vpc"
  }

}

#creating private subnet
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet
  availability_zone = "ap-southeast-1a"
  tags = {
    "Name" = "ec2_private"
  }
}

#creating the local route for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
  "Name" = "private_route_table"
  }
}

#associate the route table with private subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}

#create security group for private
resource "aws_security_group" "allow_private2smtp" {
  name = "private2smtp_sg"
  description = "Allow SMPT for private2smtp"
  vpc_id = aws_vpc.vpc.id

  egress {

    from_port        = 587
    to_port          = 587
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   tags = {
     Name = "allow_private2public_subnet"
   }
}

# Creating the Simple Email Service
resource "aws_ses_email_identity" "ses-email" {
  email = var.email
}

resource "aws_iam_user" "smtp_user" {
  name = var.smtp_username
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = var.ses_sender
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

# Creating the endpoint to test via non-internet env
resource "aws_vpc_endpoint" "smtp_ep" {
  security_group_ids  = [aws_security_group.allow_private2smtp.id]
  service_name        = var.ses_svc_ep_name
  vpc_endpoint_type   = var.ses_vpc_ep_type
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true
  tags = {
    "Name" = "ses_vpc_ep"
  }
  vpc_id = aws_vpc.vpc.id
}