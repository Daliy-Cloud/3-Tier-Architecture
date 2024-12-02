resource "aws_cloudwatch_dashboard" "cw" {
  dashboard_name = "wsc-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", "${aws_lb.alb.arn_suffix}"
            ],
            [
              "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_lb.alb.arn_suffix}"
            ]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "HTTP_5XX"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", "${aws_lb.alb.arn_suffix}"],
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", "${aws_lb.alb.arn_suffix}"]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "HTTP_4XX"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${aws_lb.alb.arn_suffix}"]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "HTTP_COUNT"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.alb.arn_suffix}"]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "RESPONSE_TIME"
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${aws_autoscaling_group.app.name}"]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "ASG_CPU"
        }
      }
    ]
  })

  depends_on = [
    aws_lb.alb,
    aws_autoscaling_group.app
  ]
}