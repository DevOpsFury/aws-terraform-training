# Allow see EC2 tags and send metric data to cloudwatch
data "aws_iam_policy_document" "cloudwatch_send_metrics" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}

# service allowed to do stuff
data "aws_iam_policy_document" "ec2_principal" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Allow EC2 to get stuff done
resource "aws_iam_role" "default" {
  name               = "ec2-default-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_principal.json}"
}

# Allow send metrics to CloudWatch
resource "aws_iam_role_policy" "monitoring" {
  name   = "ec2-monitoring"
  role   = "${aws_iam_role.default.id}"
  policy = "${data.aws_iam_policy_document.cloudwatch_send_metrics.json}"
}

# Used for attaching to launched EC2 instances via launch configuration
resource "aws_iam_instance_profile" "ec2_default" {
  name = "default-ec2-profile"
  role = "${aws_iam_role.default.name}"
}
