resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.env}-backend-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = "${var.env}-key-pair"

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region
    account_id = var.account_id
  }))


  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.security_group]
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name_prefix          = "backend-asg-"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.env}-backend"
    propagate_at_launch = true
  }
}
