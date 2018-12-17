resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }

  alarm_description = "CPU Utilization high"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "cpu-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }

  alarm_description = "CPU Utilization low"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }

  alarm_description = "Memory Utilization high"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  alarm_name          = "memory-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.application.name}"
  }

  alarm_description = "Memory Utilization low"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]
}
