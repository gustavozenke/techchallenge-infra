terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.name, "--output", "json"]
      command     = "aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# Configure backend - terraform.tfstate
terraform {
  backend "s3" {
    bucket = "tech-challenge-terraform-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
