variable "region" {
  type        = string
  description = "AWS Region"
}

variable "query_override" {
  type        = string
  nullable    = true
  description = "Override query for datadog archive. If null would be used query 'env:{stage} OR account:{aws account id} OR {additional_query_tags}'"
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


