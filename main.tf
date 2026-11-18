provider "aws" {
  region = var.region

}

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
    Region      = data.aws_region.current.region
  }
}


resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value % length(data.aws_availability_zones.available.names)]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}


resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}