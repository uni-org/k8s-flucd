terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.5.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.10"
    }
  }
  backend "s3" {
    bucket = "terraform-bucket-created-by-unimin"
    region = "ap-northeast-1"
    key    = "fluxcd/terraform.tfstate"
  }
  required_version = "~>1.11.1"
}

provider "gitlab" {
  token = var.gitlab_token
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://gitlab.com/unimin/k8s-fluxcd"
    http = {
      username = "unimin"
      password = var.gitlab_token
    }
  }
}