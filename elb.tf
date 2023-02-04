# LOAD BALANCER
resource "aws_lb" "load_balancer_nab" {
  name               = "alb-nginx-terraform"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-load-balancer.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false # [Bool: true | false]

  tags       = {
      Terraform = "true"
      Environment = "staging"
      Owner = "Aderly-Flores"
      Name = "alb-nginx-terraform"
  }
  depends_on = [aws_autoscaling_group.asg-nginx]
}

# LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "alb_target_nab" {
  name        = "tg-nginx-terraform"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  depends_on = [aws_lb.load_balancer_nab]
}

# LISTENER PORT 80
resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.load_balancer_nab.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_nab.arn
  }
  depends_on        = [aws_lb_target_group.alb_target_nab]
}

# ATTACHMENT LOAD BALANCER - AUTO SCALING GROUP
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.asg-nginx.name
  alb_target_group_arn   = aws_lb_target_group.alb_target_nab.arn
  depends_on             = [aws_autoscaling_group.asg-nginx, aws_lb_target_group.alb_target_nab]
}

