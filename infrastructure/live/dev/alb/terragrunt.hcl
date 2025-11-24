terraform {
  source = "../../../modules//alb"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "vpc-fake"
    public_subnet_ids = ["subnet-fake-pub-1", "subnet-fake-pub-2"]
  }
}

dependency "security" {
  config_path = "../security"
  mock_outputs = {
    alb_sg_id = "sg-fake-alb"
  }
}

dependency "lambda_public" {
  config_path = "../lambda-public"
  mock_outputs = {
    function_arn  = "arn:aws:lambda:us-east-1:123456789012:function:public"
    function_name = "public-lambda"
  }
}

dependency "lambda_private" {
  config_path = "../lambda-private"
  mock_outputs = {
    function_arn  = "arn:aws:lambda:us-east-1:123456789012:function:private"
    function_name = "private-lambda"
  }
}

dependency "vpn" {
  config_path = "../vpn"
  mock_outputs = {
    public_ip = "1.2.3.4"
  }
}

inputs = {
  vpc_id              = dependency.vpc.outputs.vpc_id
  public_subnet_ids   = dependency.vpc.outputs.public_subnet_ids
  security_group_ids  = [dependency.security.outputs.alb_sg_id]
  public_lambda_arn   = dependency.lambda_public.outputs.function_arn
  public_lambda_name  = dependency.lambda_public.outputs.function_name
  private_lambda_arn  = dependency.lambda_private.outputs.function_arn
  private_lambda_name = dependency.lambda_private.outputs.function_name
  vpn_server_ip       = dependency.vpn.outputs.public_ip
}

