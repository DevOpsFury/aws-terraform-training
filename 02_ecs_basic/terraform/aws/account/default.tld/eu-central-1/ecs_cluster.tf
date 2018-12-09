# https://registry.terraform.io/modules/azavea/ecs-cluster/aws/2.0.0
module "ecs-cluster" {
  source  = "azavea/ecs-cluster/aws"
  version = "2.0.0"

  vpc_id = "${aws_vpc.main.id}"

  instance_type = "t2.small"
  key_name      = "${aws_key_pair.admin.key_name}"

  cloud_config_content = ""

  root_block_device_type = "gp2"
  root_block_device_size = "10"

  health_check_grace_period = "600"
  desired_capacity          = "1"
  min_size                  = "1"
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

  project           = "Something"
  environment       = "Staging"
  lookup_latest_ami = "true"      # fails if set to false :( (bug)
}

resource "aws_security_group_rule" "container_instance_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${module.ecs-cluster.container_instance_security_group_id}"
}

resource "aws_security_group_rule" "container_instance_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${module.ecs-cluster.container_instance_security_group_id}"
}

# https://github.com/anrim/terraform-aws-ecs (cluster + ALB + service definition + task)
# https://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html
# https://medium.com/@ahmetatalay/building-highly-available-scalable-and-reliable-ecs-clusters-part-2-deploying-microservices-5eb4816b84b
# https://github.com/TechnologyMinimalists/aws-containers-task-definitions
# https://medium.com/boltops/gentle-introduction-to-how-aws-ecs-works-with-example-tutorial-cea3d27ce63d

