variable "region" {
  type        = string
  description = "AWS Region"
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

variable "enable_glacier_transition" {
  type        = bool
  description = "Enable/disable transition to glacier for log archive bucket. Has no effect unless lifecycle_rules_enabled set to true"
  default     = true
}

variable "glacier_transition_days" {
  type        = number
  description = "Number of days after which to transition objects to glacier storage in log archive bucket"
  default     = 365
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

variable "expiration_days" {
  type        = number
  description = "Number of days after which to expire current version objects in S3 bucket. Set to 0 to disable expiration"
  default     = 0
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "Number of days after which to expire noncurrent version objects in S3 bucket. Set to 0 to disable expiration"
  default     = 0
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  description = "Number of days after which to abort incomplete multipart uploads. Set to null to disable"
  default     = null
}

variable "noncurrent_version_glacier_transition_days" {
  type        = number
  description = "Number of days after which to transition noncurrent versions to glacier storage"
  default     = 30
}

variable "enable_deeparchive_transition" {
  type        = bool
  description = "Enable/disable transition to deep archive storage"
  default     = false
}

variable "deeparchive_transition_days" {
  type        = number
  description = "Number of days after which to transition objects to deep archive storage"
  default     = 0
}

variable "noncurrent_version_deeparchive_transition_days" {
  type        = number
  description = "Number of days after which to transition noncurrent versions to deep archive storage"
  default     = 0
}

variable "enable_standard_ia_transition" {
  type        = bool
  description = "Enable/disable transition to standard IA storage"
  default     = false
}

variable "standard_transition_days" {
  type        = number
  description = "Number of days after which to transition objects to standard IA storage"
  default     = 0
}

variable "cloudtrail_abort_incomplete_multipart_upload_days" {
  type        = number
  description = "Number of days after which to abort incomplete multipart uploads for cloudtrail bucket. Set to null to disable"
  default     = null
}

variable "cloudtrail_enable_glacier_transition" {
  type        = bool
  description = "Enable/disable transition to glacier for cloudtrail bucket"
  default     = true
}

variable "cloudtrail_glacier_transition_days" {
  type        = number
  description = "Number of days after which to transition cloudtrail objects to glacier storage"
  default     = 365
}

variable "cloudtrail_noncurrent_version_glacier_transition_days" {
  type        = number
  description = "Number of days after which to transition cloudtrail noncurrent versions to glacier storage"
  default     = 365
}

variable "cloudtrail_enable_deeparchive_transition" {
  type        = bool
  description = "Enable/disable transition to deep archive storage for cloudtrail bucket"
  default     = false
}

variable "cloudtrail_deeparchive_transition_days" {
  type        = number
  description = "Number of days after which to transition cloudtrail objects to deep archive storage"
  default     = 0
}

variable "cloudtrail_noncurrent_version_deeparchive_transition_days" {
  type        = number
  description = "Number of days after which to transition cloudtrail noncurrent versions to deep archive storage"
  default     = 0
}

variable "cloudtrail_enable_standard_ia_transition" {
  type        = bool
  description = "Enable/disable transition to standard IA storage for cloudtrail bucket"
  default     = false
}

variable "cloudtrail_standard_transition_days" {
  type        = number
  description = "Number of days after which to transition cloudtrail objects to standard IA storage"
  default     = 0
}

variable "cloudtrail_expiration_days" {
  type        = number
  description = "Number of days after which to expire current version cloudtrail objects. Set to 0 to disable expiration"
  default     = 0
}

variable "cloudtrail_noncurrent_version_expiration_days" {
  type        = number
  description = "Number of days after which to expire noncurrent version cloudtrail objects. Set to 0 to disable expiration"
  default     = 0
}
