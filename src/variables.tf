variable "region" {
  type        = string
  description = "AWS Region"
}

variable "query_override" {
  type        = string
  nullable    = true
  description = "Override query for datadog archive. If null would be used query 'env:{stage} OR account:{aws account id} OR {additional_query_tags}'"
  default     = null
}

variable "archive_name" {
  type        = string
  nullable    = true
  description = "Name of the Datadog logs archive. Datadog logs archive names must be unique within a Datadog organization, so this defaults to the globally unique module ID (`module.this.id`) when null."
  default     = null
}

variable "additional_query_tags" {
  type        = list(any)
  description = "Additional tags to be used in the query for this archive"
  default     = []
}

variable "catchall_enabled" {
  type        = bool
  description = "Set to true to enable a catchall for logs unmatched by any queries. This should only be used in one environment/account"
  default     = false
}

variable "catchall_archive_name" {
  type        = string
  nullable    = true
  description = "Name of the catchall Datadog logs archive. Datadog logs archive names must be unique within a Datadog organization, so this defaults to `<module.this.id>-catchall` when null."
  default     = null
}

variable "compression_method" {
  type        = string
  description = <<-EOT
    Compression method Datadog uses when writing objects to the archive. One of `ZSTD` or `GZIP`.

    Defaults to `ZSTD`, which is the default and the recommendation in the Datadog console,
    especially where Archive Search is used. `ZSTD` objects are smaller than `GZIP`, so they cost
    less to store, less to scan (Archive Search and rehydration are both billed on the volume
    scanned) and less in egress from the archive bucket. The Datadog provider defaults to `GZIP`.
  EOT
  default     = "ZSTD"

  validation {
    condition     = contains(["ZSTD", "GZIP"], var.compression_method)
    error_message = "compression_method must be ZSTD or GZIP."
  }
}

variable "partitioning_attributes" {
  type        = list(string)
  nullable    = true
  description = <<-EOT
    Up to two low cardinality attributes used as partition keys for the archive, most frequently
    queried first. Logs sharing a partition value are co-located, so a search can skip partitions
    that cannot match before downloading them.

    This is the only setting that decouples scan size from the length of the searched time range.
    The query filter is applied after the matching files are downloaded, so an unpartitioned
    archive scans the whole window regardless of how selective the query is.

    Only logs archived after this is set are partitioned. Null leaves the archive unpartitioned.
  EOT
  default     = null

  validation {
    condition     = var.partitioning_attributes == null ? true : length(var.partitioning_attributes) <= 2
    error_message = "Datadog allows at most 2 partitioning attributes per archive."
  }
}

variable "lookup_attributes" {
  type        = list(string)
  nullable    = true
  description = <<-EOT
    Up to two high cardinality attributes (trace ID, container ID, user ID) used to pinpoint
    individual logs within a data block, reducing both the volume scanned and egress from the
    archive bucket.

    Only logs archived after this is set benefit. Null disables lookup acceleration.
  EOT
  default     = null

  validation {
    condition     = var.lookup_attributes == null ? true : length(var.lookup_attributes) <= 2
    error_message = "Datadog allows at most 2 lookup attributes per archive."
  }
}

variable "rehydration_max_scan_size_in_gb" {
  type        = number
  nullable    = true
  description = <<-EOT
    Maximum volume, in GB, that a single job may scan against this archive.

    Despite the field name, which predates Archive Search, this is one per-archive setting that
    caps Archive Search queries and rehydration jobs alike. Null means no limit, so a single wide
    search can scan the entire archive and bill the corresponding egress.
  EOT
  default     = null
}

variable "lifecycle_rules_enabled" {
  type        = bool
  description = "Enable/disable lifecycle management rules for log archive s3 objects"
  default     = true
}

variable "archive_lifecycle_config" {
  type = object({
    abort_incomplete_multipart_upload_days         = optional(number, null)
    enable_glacier_transition                      = optional(bool, true)
    glacier_transition_days                        = optional(number, 365)
    glacier_transition_storage_class               = optional(string, "GLACIER_IR")
    noncurrent_version_glacier_transition_days     = optional(number, 30)
    enable_deeparchive_transition                  = optional(bool, false)
    deeparchive_transition_days                    = optional(number, 0)
    noncurrent_version_deeparchive_transition_days = optional(number, 0)
    enable_standard_ia_transition                  = optional(bool, false)
    standard_transition_days                       = optional(number, 0)
    expiration_days                                = optional(number, 0)
    noncurrent_version_expiration_days             = optional(number, 0)
  })
  description = "Lifecycle configuration for the archive S3 bucket"
  default     = {}

  validation {
    condition     = contains(["GLACIER_IR", "GLACIER"], var.archive_lifecycle_config.glacier_transition_storage_class)
    error_message = "glacier_transition_storage_class must be GLACIER_IR or GLACIER. Datadog cannot read GLACIER (S3 Glacier Flexible Retrieval) for Rehydration or Archive Search, because those objects require s3:RestoreObject first and the archive role is not granted that action. Use GLACIER_IR unless the archive never needs to be read back."
  }
}

variable "cloudtrail_lifecycle_config" {
  type = object({
    abort_incomplete_multipart_upload_days         = optional(number, null)
    enable_glacier_transition                      = optional(bool, true)
    glacier_transition_days                        = optional(number, 365)
    noncurrent_version_glacier_transition_days     = optional(number, 365)
    enable_deeparchive_transition                  = optional(bool, false)
    deeparchive_transition_days                    = optional(number, 0)
    noncurrent_version_deeparchive_transition_days = optional(number, 0)
    enable_standard_ia_transition                  = optional(bool, false)
    standard_transition_days                       = optional(number, 0)
    expiration_days                                = optional(number, 0)
    noncurrent_version_expiration_days             = optional(number, 0)
  })
  description = "Lifecycle configuration for the cloudtrail S3 bucket"
  default     = {}
}


variable "object_lock_days_archive" {
  type        = number
  description = "Object lock duration for archive buckets in days"
  default     = 7
}

variable "object_lock_days_cloudtrail" {
  type        = number
  description = "Object lock duration for cloudtrail buckets in days"
  default     = 7
}

variable "object_lock_mode_archive" {
  type        = string
  description = "Object lock mode for archive bucket. Possible values are COMPLIANCE or GOVERNANCE"
  default     = "COMPLIANCE"
}

variable "object_lock_mode_cloudtrail" {
  type        = string
  description = "Object lock mode for cloudtrail bucket. Possible values are COMPLIANCE or GOVERNANCE"
  default     = "COMPLIANCE"
}

variable "s3_force_destroy" {
  type        = bool
  description = "Set to true to delete non-empty buckets when enabled is set to false"
  default     = false
}

variable "cloudtrail_enable_kms_encryption" {
  type        = bool
  description = "Enable KMS encryption for CloudTrail logs"
  default     = true
}

variable "cloudtrail_kms_key_arn" {
  type        = string
  description = "ARN of an existing KMS key to use for CloudTrail log encryption. If not provided and cloudtrail_enable_kms_encryption is true, a new key will be created"
  default     = null
  nullable    = true
}

variable "cloudtrail_create_kms_key" {
  type        = bool
  description = "Create a new KMS key for CloudTrail encryption. Only used if cloudtrail_kms_key_arn is not provided and cloudtrail_enable_kms_encryption is true"
  default     = true
}

variable "cloudtrail_kms_key_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the KMS key is deleted after destruction of the resource, must be between 7 and 30 days"
  default     = 10
}

variable "cloudtrail_kms_key_enable_rotation" {
  type        = bool
  description = "Enable automatic rotation of the KMS key"
  default     = true
}

variable "access_log_bucket_enabled" {
  type        = bool
  description = "Whether to create a dedicated S3 bucket for CloudTrail bucket access logs"
  default     = false
}

variable "access_log_bucket_name" {
  type        = string
  description = "Name of existing S3 bucket to use for CloudTrail bucket access logs. Only used when access_log_bucket_enabled is false"
  default     = ""
}
