terraform {
  source = "../../../modules//lambda"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnet_ids = ["subnet-fake-private"]
  }
}

dependency "security" {
  config_path = "../security"
  mock_outputs = {
    lambda_private_sg_id = "sg-fake-lambda-private"
  }
}

inputs = {
  function_name      = "teachy-infra-private-lambda"
  image_uri          = get_env("TF_VAR_private_lambda_image", "public.ecr.aws/lambda/python:3.9")
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids
  security_group_ids = [dependency.security.outputs.lambda_private_sg_id]
  environment_variables = {
    TYPE = "private"
  }
}

