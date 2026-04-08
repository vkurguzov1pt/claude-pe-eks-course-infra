locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Component = "bootstrap"
  }

  account_id      = data.aws_caller_identity.current.account_id
  thumbprint_list = data.tls_certificate.github.certificates[0].sha1_fingerprint
}