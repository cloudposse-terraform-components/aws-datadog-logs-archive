# KMS key policy document for CloudTrail encryption
data "aws_iam_policy_document" "cloudtrail_kms_key_policy" {
  count = local.enabled && var.cloudtrail_enable_kms_encryption && var.cloudtrail_create_kms_key && var.cloudtrail_kms_key_arn == null ? 1 : 0

  # Enable IAM User Permissions
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.aws_partition}:iam::${local.aws_account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  # Allow CloudTrail to encrypt logs
  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.aws_partition}:cloudtrail:*:${local.aws_account_id}:trail/${module.this.id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${local.aws_partition}:cloudtrail:${var.region}:${local.aws_account_id}:trail/${module.this.id}"]
    }
  }

  # Allow CloudTrail to describe key
  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # Allow principals in the account to decrypt log files
  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.aws_partition}:iam::${local.aws_account_id}:root"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.aws_account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${local.aws_partition}:cloudtrail:*:${local.aws_account_id}:trail/*"]
    }
  }

  # Allow alias creation during resource creation
  statement {
    sid    = "Allow alias creation during resource creation"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${local.aws_partition}:iam::${local.aws_account_id}:root"]
    }
    actions = [
      "kms:CreateAlias"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.aws_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
  }
}

# KMS key for CloudTrail encryption
resource "aws_kms_key" "cloudtrail" {
  count = local.enabled && var.cloudtrail_enable_kms_encryption && var.cloudtrail_create_kms_key && var.cloudtrail_kms_key_arn == null ? 1 : 0

  description             = "KMS key for CloudTrail log encryption - ${module.this.id}"
  deletion_window_in_days = var.cloudtrail_kms_key_deletion_window_in_days
  enable_key_rotation     = var.cloudtrail_kms_key_enable_rotation
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_key_policy[0].json

  tags = merge(
    module.this.tags,
    {
      Name       = "${module.this.id}-cloudtrail"
      managed-by = "terraform"
      env        = var.stage
      service    = "datadog-logs-archive"
      part-of    = "observability"
    }
  )
}

# KMS key alias for easier identification
resource "aws_kms_alias" "cloudtrail" {
  count = local.enabled && var.cloudtrail_enable_kms_encryption && var.cloudtrail_create_kms_key && var.cloudtrail_kms_key_arn == null ? 1 : 0

  name          = "alias/${module.this.id}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}
