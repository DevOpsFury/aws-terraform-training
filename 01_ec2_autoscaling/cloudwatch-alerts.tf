resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
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

  alarm_description = "CPU Utilization"
  #alarm_actions     = ["${var.alerting_sns_topic}"]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
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

  alarm_description = "Memory Utilization"
  #alarm_actions     = ["${var.alerting_sns_topic}"]
}
