variable "budget_alert_email" {
  type        = string
  description = "Email address for the monthly budget alert. Set with TF_VAR_budget_alert_email. Do not commit the address."
  sensitive   = true
}
