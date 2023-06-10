provider "aws" {
  region = "us-east-1"
}   

variable "subnet_cidr_block" {
  description = "subnet cidr block"
  }

variable "vpc_cidr_block" {
  description = "vpc_cidr_block"
  }

  variable avail_zone {} 

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags =  {
    Name: "development"
  }
  
}

resource "aws_subnet" "dev-subnet1" {
  vpc_id = aws_vpc.development-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags =  {
    Name: "subnet1-dev"
  }
  
}
