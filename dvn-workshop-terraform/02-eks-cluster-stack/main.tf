terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  backend "s3" {
    bucket       = "workshop-s3-remote-backend-bucket"
    key          = "eks-cluster-stack/terraform.tfstate"
    region       = "us-west-1"
    use_lockfile = true
    # dynamodb_table = "workshop-s3-state-locking-table"
  }
}

provider "aws" {
  region = var.auth.region

  assume_role {
    role_arn = var.auth.assume_role_arn
  }

  default_tags {
    tags = var.tags
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.id]
      command     = "aws"
    }
  }
}
