locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  aws_region   = local.env_vars.locals.aws_region
  project_name = local.env_vars.locals.project_name
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "teachy-tf-state-${get_env("USERNAME", "user")}-unique-id" # USANDO VARIAVEL DE AMBIENTE DO WINDOWS PARA EVITAR CONFLITO
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global inputs that are passed to all modules
inputs = {
  project_name = local.project_name
  aws_region   = local.aws_region
}

