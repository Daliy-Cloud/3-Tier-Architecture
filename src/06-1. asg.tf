resource "aws_autoscaling_group" "app" {
  name                = "wsc-app-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 20
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  target_group_arns   = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wsc-app-asg"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "app" {
  name                   = "web-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.app.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

resource "aws_launch_template" "app" {
  name          = "wsc-app-tp"
  image_id      = data.aws_ssm_parameter.latest_ami.value
  instance_type = "t3.micro"
  key_name      = aws_key_pair.keypair.key_name
  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  vpc_security_group_ids = [aws_security_group.app.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wsc-app-asg"
    }
  }

  user_data = base64encode("${file("./src/app_userdata.sh")}")

  depends_on = [
    aws_rds_cluster.db,
    aws_rds_cluster_instance.db,
    aws_secretsmanager_secret.db,
    aws_secretsmanager_secret_version.db,
    aws_instance.bastion,
    aws_ecr_repository.ecr
  ]
}