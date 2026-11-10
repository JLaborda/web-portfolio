terraform {
  required_version = "1.16.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.69.1"
    }
  }

  # Bucket and key are supplied with -backend-config at init. The account id is not committed.
  backend "s3" {
    region       = "eu-west-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

# ACM certificates for CloudFront must live in us-east-1 (constitution III).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
