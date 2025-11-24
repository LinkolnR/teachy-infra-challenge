terraform {
  source = "../../../modules//vpc"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  enable_nat_gateway   = false # Saving costs!
}

