# Launch-template
resource "aws_launch_template" "template-nginx" {
  name = "template-nginx-terraform"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
    }
  }

  disable_api_stop        = true
  disable_api_termination = true
  ebs_optimized = false
  image_id = "ami-095413544ce52437d"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = "ubuntu-blank-factor"

  vpc_security_group_ids = [aws_security_group.sg-load-balancer.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Terraform = "true"
      Environment = "staging"
      Owner = "Aderly-Flores"
      Name = "nginx-server-asg"
    }
  }

  user_data = filebase64("${path.module}/user-data/script-nginx.sh")
}


# AUTO-SCALING-GROUP
resource "aws_autoscaling_group" "asg-nginx" {
  name                      = "asg-nginx-terraform"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.template-nginx.id
    version = aws_launch_template.template-nginx.latest_version
  }
}



# AUTO-SCALING-GROUP-POLICY
resource "aws_autoscaling_policy" "nab-cpu-policy" {
    name = "nab-cpu-policy"
    autoscaling_group_name = "${aws_autoscaling_group.asg-nginx.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
    alarm_name = "cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "65"
    dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg-nginx.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.nab-cpu-policy.arn}"]
}


resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
    name = "cpu-policy-scaledown"
    autoscaling_group_name = "${aws_autoscaling_group.asg-nginx.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
    alarm_name = "cpu-alarm-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "40"
    dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg-nginx.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.cpu-policy-scaledown.arn}"]
}

