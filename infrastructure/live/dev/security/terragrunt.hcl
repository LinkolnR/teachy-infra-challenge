terraform {
  source = "../../../modules//security"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-fake-id"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}

