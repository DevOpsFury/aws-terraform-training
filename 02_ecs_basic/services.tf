// ALB: https://foxutech.com/how-to-use-aws-application-load-balancer-and-network-load-balancer-with-ecs/
// https://github.com/npalm/terraform-aws-ecs-service
resource "aws_security_group" "allow_all" {
  name   = "${var.environment}-allow-all-sg"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535

    cidr_blocks = [
      "${aws_vpc.main.cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment}-allow-all-sg"
    Environment = "${var.environment}"
  }
}

locals {
  container_name = "nginx"
  container_port = "80"
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "nginx-ecs-task-role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_execution_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = "${aws_iam_role.ecs_tasks_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "nginx" {
  source  = "npalm/ecs-service/aws"

  service_name          = "nginx"
  service_desired_count = 1

  environment = "${var.environment}"

  vpc_id       = "${aws_vpc.main.id}"
  vpc_cidr     = "${aws_vpc.main.cidr_block}"
  enable_lb    = true
  lb_internal  = false
  lb_subnetids = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"]

  ecs_cluster_id = "${module.ecs-cluster.id}"


  task_definition = "${file("task-definitions/service.json")}" //"${data.template_file.nginx.rendered}"
  task_cpu        = "256"
  task_memory     = "512"

//  service_launch_type = "FARGATE"

  awsvpc_task_execution_role_arn = "${aws_iam_role.ecs_tasks_execution_role.arn}"
  awsvpc_service_security_groups = ["${aws_security_group.allow_all.id}"]
  awsvpc_service_subnetids       = ["${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}", "${aws_subnet.private_c.id}"]

  lb_target_group = {
    container_name = "${local.container_name}"
    container_port = "${local.container_port}"
  }

  lb_listener = {
    port     = 80
    protocol = "HTTP"
  }
}

// https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
resource "aws_cloudwatch_log_group" "nginx_log_group" {
  name = "nginx-log-group"

  retention_in_days = 1
  
  tags {
    Name = "nginx-log-group"
    Service = "${var.environment}-nginx"
  }
}