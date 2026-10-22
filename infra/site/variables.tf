variable "environment" {
  type        = string
  description = "Site environment to apply. Allowed values are staging and production. This is not CloudFront continuous-deployment staging."

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be staging or production."
  }
}
