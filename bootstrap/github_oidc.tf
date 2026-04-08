# Fetch GitHub's OIDC signing certificate dynamically
# so the thumbprint stays current if GitHub rotates their cert
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Register GitHub as a trusted identity provider in our AWS account
# This tells AWS: "tokens signed by GitHub are valid for authentication"
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.thumbprint_list]
}

# Define who can assume the GitHub Actions role and under what conditions
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    # Only tokens from our registered GitHub OIDC provider are accepted
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    # The token's audience must be "sts.amazonaws.com"
    # This confirms the token was intended for AWS, not some other service
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # The token's subject must match our specific repo
    # GitHub sets "sub" to "repo:owner/name:ref:refs/heads/branch"
    # The wildcard allows any branch — tighten to ":ref:refs/heads/main" for prod
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# The IAM role that GitHub Actions workflows will assume
resource "aws_iam_role" "github_actions" {
  name               = join("-", [var.project_name, "github-actions"])
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
