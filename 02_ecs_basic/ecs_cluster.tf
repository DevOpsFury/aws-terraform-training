# https://registry.terraform.io/modules/azavea/ecs-cluster/aws/2.0.0
module "ecs-cluster" {
  source  = "azavea/ecs-cluster/aws"
  version = "2.0.0"

  vpc_id        = "${aws_vpc.main.id}"

  instance_type = "t2.small"
  key_name      = "${aws_key_pair.admin.key_name}"

  cloud_config_content = ""

  root_block_device_type = "gp2"
  root_block_device_size = "10"

  health_check_grace_period = "600"
  desired_capacity          = "1"
  min_size                  = "0"
  max_size                  = "2"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  private_subnet_ids = ["${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}", "${aws_subnet.private_c.id}"]

  project     = "Something"
  environment = "Staging"
  lookup_latest_ami = "true" # fails if set to false :( (bug)
}

# https://github.com/anrim/terraform-aws-ecs (cluster + ALB + service definition + task)

