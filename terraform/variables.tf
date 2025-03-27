# % export TF_VAR_gitlab_token=XXXX
variable "gitlab_token" {
  description = "The GitLab token to use for authenticating against the GitLab API."
  sensitive   = true
  type        = string
  default     = ""
}
