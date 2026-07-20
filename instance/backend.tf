terraform {
  backend "s3" {
    # Backend configuration will be provided via -backend-config flags during terraform init
    # or via backend-config.hcl file
    # See backend-config.hcl for example configuration
  }
}
