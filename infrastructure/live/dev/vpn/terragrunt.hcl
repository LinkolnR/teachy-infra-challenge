terraform {
  source = "../../../modules//vpn"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    public_subnet_ids = ["subnet-fake-1"]
  }
}

dependency "security" {
  config_path = "../security"
  mock_outputs = {
    vpn_sg_id = "sg-fake-vpn"
  }
}

inputs = {
  subnet_id          = dependency.vpc.outputs.public_subnet_ids[0]
  security_group_ids = [dependency.security.outputs.vpn_sg_id]
  key_name           = get_env("TF_VAR_ssh_key_name", "teachy-vpn-key")
}

