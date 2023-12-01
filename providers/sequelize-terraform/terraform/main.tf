terraform {
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
    atlas = {
      source  = "ariga/atlas"
      version = "0.6.0"
    }
  }
}
