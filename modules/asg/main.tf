resource "aws_launch_configuration" "backend_lc" {
  name_prefix                 = "${var.env}-backend-lc-"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  security_groups             = [var.security_group]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name_prefix          = "backend-asg-"
  launch_configuration = aws_launch_configuration.backend_lc.id
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = [var.lb_arn]

  tag {
    key        = "Name"
    value      = "${var.env}-backend"         
    propagate_at_launch = true
  }
}