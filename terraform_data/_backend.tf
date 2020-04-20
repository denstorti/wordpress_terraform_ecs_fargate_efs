terraform {
  required_version = ">= 0.12.24"
  backend "s3" {
    # configured with init parameters using env vars

    workspaces {
      name = "data"
    }
  }
}