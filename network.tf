module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "blankfactor-vpc"
  cidr = "10.8.0.0/16"

  azs = var.zones  
  private_subnets = ["10.8.1.0/24", "10.8.2.0/24"]
  public_subnets  = ["10.8.101.0/24", "10.8.102.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "Aderly-Flores"
  }
}

# ACL RULE
# resource "aws_network_acl" "main" {
#   vpc_id = module.vpc.vpc_id

#   egress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "38.25.22.14/32"
#     from_port  = 32768
#     to_port    = 65535
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "38.25.22.14/32"
#     from_port  = 80
#     to_port    = 80
#   }

#   tags = {
#     Name = "main"
#   }
# }