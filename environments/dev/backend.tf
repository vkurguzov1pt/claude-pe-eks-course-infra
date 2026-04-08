terraform {
  backend "s3" {
    bucket       = "claude-eks-pe-tf-state-616750136093"
    key          = "environments/dev/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}