resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.application.name}"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-up"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.application.name}"
} 

