module "kms_key_archive" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  description             = "KMS key for Datadog Log Archives"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = join("", data.aws_iam_policy_document.kms_key_archive[*].json)

  context = module.this.context
}

data "aws_iam_policy_document" "kms_key_archive" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format("arn:${local.aws_partition}:iam::%s:root", local.aws_account_id)
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to use the key" 
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        format("arn:${local.aws_partition}:cloudtrail:*:%s:trail/*", local.aws_account_id)
      ]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format("arn:${local.aws_partition}:iam::%s:role/${local.datadog_aws_role_name}", local.aws_account_id)
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt", 
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format("arn:${local.aws_partition}:iam::%s:role/${local.datadog_aws_role_name}", local.aws_account_id)
      ]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
