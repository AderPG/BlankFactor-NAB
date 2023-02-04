module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "aurora-db-postgres96"
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instance_class = "db.r6g.large"
  instances = {
    one = {}
    2 = {
      instance_class = "db.t3.medium"
    }
  }

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  allowed_security_groups = [aws_security_group.sg-rds.id]
  #allowed_cidr_blocks     = ["10.20.0.0/20"]

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  #db_parameter_group_name         = "default.postgres12"
  #db_cluster_parameter_group_name = "default"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
      Terraform = "true"
      Environment = "staging"
      Owner = "Aderly-Flores"

  }
}