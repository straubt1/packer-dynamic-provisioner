variable "gcp_configuration" {
  description = ""
  type = object(
    {
      zone             = string
      project_id       = string
      credentials_file = string
    }
  )
  default = {
    zone             = env("GCP_ZONE")
    project_id       = env("GCP_PROJECT_ID")
    credentials_file = env("GCP_CREDENTIALS_FILE")
  }
}