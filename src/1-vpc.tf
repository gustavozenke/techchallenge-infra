# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name}-vpc"
  }

  lifecycle {
    prevent_destroy = false
  }
}

#VPC Security Group
resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

#VPC Link
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.cluster_name}-vpc-link"
  target_arns = [data.aws_lb.ingress_lb.arn]
}

#VPC Endpoint
resource "aws_vpc_endpoint" "vpc_endpoint" {
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.eks_security_group.id]
  service_name        = "com.amazonaws.${var.aws_region}.execute-api"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.vpc.id
}
