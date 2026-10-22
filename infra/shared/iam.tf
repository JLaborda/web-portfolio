data "aws_caller_identity" "current" {}

locals {
  account_id        = data.aws_caller_identity.current.account_id
  state_bucket      = "web-portfolio-tfstate-${local.account_id}"
  staging_bucket    = "web-portfolio-staging-${local.account_id}"
  production_bucket = "web-portfolio-production-${local.account_id}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # SHA-1 of the last certificate in the chain served by
  # token.actions.githubusercontent.com on 2026-10-21.
  # Subject CN=Root YR, O=ISRG. Issuer CN=ISRG Root X1.
  thumbprint_list = ["ab9d0263244dd0326eb67015705a667e79cfe998"]
}

data "aws_iam_policy_document" "plan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:JLaborda@15078416/web-portfolio@1427090788:pull_request"]
    }
  }
}

data "aws_iam_policy_document" "plan" {
  statement {
    sid    = "ReadStateAndSiteBuckets"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::${local.state_bucket}",
      "arn:aws:s3:::${local.state_bucket}/*",
      "arn:aws:s3:::${local.staging_bucket}",
      "arn:aws:s3:::${local.staging_bucket}/*",
      "arn:aws:s3:::${local.production_bucket}",
      "arn:aws:s3:::${local.production_bucket}/*",
    ]
  }

  statement {
    sid    = "ReadIam"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListOpenIDConnectProviders",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadCloudFront"
    effect = "Allow"
    actions = [
      "cloudfront:Describe*",
      "cloudfront:Get*",
      "cloudfront:List*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadBudget"
    effect = "Allow"
    actions = [
      "budgets:ListTagsForResource",
      "budgets:ViewBudget",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyPlanWrites"
    effect = "Deny"
    actions = [
      "budgets:ModifyBudget",
      "cloudfront:CreateInvalidation",
      "cloudfront:UpdateDistribution",
      "iam:CreateRole",
      "s3:DeleteObject",
      "s3:PutObject",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "plan" {
  name               = "web-portfolio-plan"
  description        = "Read-only role for terraform plan on pull requests."
  assume_role_policy = data.aws_iam_policy_document.plan_trust.json
}

resource "aws_iam_role_policy" "plan" {
  name   = "web-portfolio-plan"
  role   = aws_iam_role.plan.name
  policy = data.aws_iam_policy_document.plan.json
}

data "aws_iam_policy_document" "staging_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:JLaborda@15078416/web-portfolio@1427090788:environment:staging"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:ref"
      values   = ["refs/heads/develop"]
    }
  }
}

data "aws_iam_policy_document" "staging_deploy" {
  statement {
    sid       = "ListStagingBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.staging_bucket}"]
  }

  statement {
    sid    = "WriteStagingObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${local.staging_bucket}/*"]
  }
}

resource "aws_iam_role" "staging_deploy" {
  name               = "web-portfolio-staging-deploy"
  description        = "Deploy role for the staging site. Trusts GitHub Environment staging on develop."
  assume_role_policy = data.aws_iam_policy_document.staging_trust.json
}

resource "aws_iam_role_policy" "staging_deploy" {
  name   = "web-portfolio-staging-deploy"
  role   = aws_iam_role.staging_deploy.name
  policy = data.aws_iam_policy_document.staging_deploy.json
}

data "aws_iam_policy_document" "production_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:JLaborda@15078416/web-portfolio@1427090788:environment:production"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:ref"
      values   = ["refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "production_deploy" {
  statement {
    sid       = "ListProductionBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.production_bucket}"]
  }

  statement {
    sid    = "WriteProductionObjects"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::${local.production_bucket}/*"]
  }
}

resource "aws_iam_role" "production_deploy" {
  name               = "web-portfolio-production-deploy"
  description        = "Deploy role for the production site. Trusts GitHub Environment production on main."
  assume_role_policy = data.aws_iam_policy_document.production_trust.json
}

resource "aws_iam_role_policy" "production_deploy" {
  name   = "web-portfolio-production-deploy"
  role   = aws_iam_role.production_deploy.name
  policy = data.aws_iam_policy_document.production_deploy.json
}
