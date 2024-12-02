data "aws_ec2_managed_prefix_list" "cloudfront" {
 name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb" {
  name        = "wsc-ALB-SG"
  description = "wsc-ALB-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  
  egress {
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "wsc-ALB-SG"
  }
}

resource "aws_lb" "alb" {
  name               = "wsc-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]

  tags = {
    Name = "wsc-app-alb"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.app.arn
        weight = 100
      }
    }
  }
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.alb.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = ["/v1/user"]
    }
  }
}

resource "aws_lb_target_group" "app" {
  name        = "wsc-app-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    port                = 8080
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/healthcheck"
  }

  tags = {
    Name = "wsc-app-tg"
  }
}