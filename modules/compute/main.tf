resource "aws_launch_template" "dr_launch_template" {
  name          = "dr-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    security_groups             = var.security_group_ids
    associate_public_ip_address = false
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "DR-Instance"
    }
  }
}

resource "aws_autoscaling_group" "dr_asg" {
  count               = var.dr_activated ? 1 : 0
  name                = "dr-autoscaling-group"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.dr_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "DR-AutoScaled-Instance"
    propagate_at_launch = true
  }
}

resource "aws_instance" "dr_instances" {
  count         = var.dr_activated ? var.instance_count : 0
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index % length(var.subnet_ids))

  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "DR-Instance-${count.index}"
  }
}

resource "aws_lb" "dr_lb" {
  count              = var.dr_activated && var.create_load_balancer ? 1 : 0
  name               = "dr-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = {
    Name = "DR-Load-Balancer"
  }
}

resource "aws_lb_target_group" "dr_target_group" {
  count       = var.dr_activated && var.create_load_balancer ? 1 : 0
  name        = "dr-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "dr_listener" {
  count             = var.dr_activated && var.create_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.dr_lb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dr_target_group[0].arn
  }
}

resource "aws_lb_target_group_attachment" "dr_target_group_attachment" {
  count            = var.dr_activated && var.create_load_balancer ? var.instance_count : 0
  target_group_arn = aws_lb_target_group.dr_target_group[0].arn
  target_id        = aws_instance.dr_instances[count.index].id
  port             = 80
}