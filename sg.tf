resource "aws_security_group" "sg-load-balancer" {
  name        = "sg_load_balancer"
  description = "Allow external traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["38.25.22.14/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "Aderly-Flores"
  }
}

output "sg_id" {
    value = aws_security_group.sg-load-balancer.id
}

resource "aws_security_group" "sg-nginx-server" {
  name        = "sg_nginx"
  description = "Allow access from elb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.sg-load-balancer.id]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [aws_security_group.sg-load-balancer.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Terraform = "true"
    Environment = "stagging"
    Owner = "Aderly-Flores"
  }
}

resource "aws_security_group" "sg-rds" {
  name        = "sg_rds"
  description = "Allow  traffic bd"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_security_group.sg-nginx-server.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "Aderly-Flores"
  }
}