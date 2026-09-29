terraform {
  # The variable `nullable` argument used in variables.tf requires Terraform 1.1, and the
  # Datadog provider has required Terraform 1.1.5 since its 4.0.0 release, so the floor below
  # is already enforced transitively by the provider constraint rather than being a new
  # restriction. Declaring 0.13.0 was inaccurate for a configuration that cannot run on it.
  required_version = ">= 1.1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0, < 6.0.0"
    }
    # 4.13.0 is the first release carrying every `datadog_logs_archive` attribute this
    # component sets: `rehydration_max_scan_size_in_gb` landed in 3.12.0,
    # `compression_method` in 4.10.0, and `partitioning_attributes` and
    # `lookup_attributes` in 4.13.0. Anything older fails schema validation.
    datadog = {
      source  = "datadog/datadog"
      version = ">= 4.13.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 2.1.0"
    }
  }
}
