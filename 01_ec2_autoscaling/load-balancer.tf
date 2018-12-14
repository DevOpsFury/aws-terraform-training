# Old LB
resource "aws_elb" "default-elb" {
  name = "default-elb"

  # The same availability zone as our instances
  security_groups = [
    "${aws_security_group.http_server_public.id}",
  ]

  subnets = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_autoscaling_group" "application_alb" {
#     name = "myALB"
#     launch_configuration = "${aws_launch_configuration.as_conf.name}"


#     vpc_zone_identifier = ["${var.subnets}"]


#     min_size = "${var.min_size}"
#     max_size = "${var.max_size}"
#     desired_capacity = "${var.desired_size}"


#     target_group_arns = ["${aws_alb_target_group.default.arn}"]


#     termination_policies = ["OldestInstance"]


#     lifecycle {
#       create_before_destroy = true
#     }


#     # Tag all instances
#     tag {
#       key                 = "Name"
#       value               = "ASG: ${var.name}"
#       propagate_at_launch = true
#     }


# }


# resource "aws_alb" "default-alb" {
#     name = "myALB"


#     # The same availability zone as our instances
#     security_groups = [
#       "${aws_security_group.http_server_public.id}",
#     ]


#     subnets = ["${var.subnets}"]


#     lifecycle {
#       create_before_destroy = true
#     }
# }


# resource "aws_alb_listener" "default_http" {
#     load_balancer_arn = "${aws_alb.default-alb.arn}"
#     port = "80"
#     protocol = "HTTP"


#     # ssl_policy = "ELBSecurityPolicy-2015-05"
#     # certificate_arn = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"


#     default_action {
#       target_group_arn = "${aws_alb_target_group.default.arn}"
#       type = "forward"
#     }
# }


# resource "aws_alb_target_group" "default" {
#     name     = "${var.name}"
#     port     = 80
#     protocol = "HTTP"


#     health_check {
#       interval            = 30
#       path                = "/"
#       port                = "traffic-port" # or any specific port
#       protocol            = "HTTP"
#       timeout             = 3
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       matcher             = "200"
#     }


#     vpc_id   = "${aws_vpc.main.id}"
# }


# resource "aws_alb_listener_rule" "static" {
#     listener_arn = "${aws_alb_listener.default_http.arn}"
#     priority = 100


#     action {
#       type = "forward"
#       target_group_arn = "${aws_alb_target_group.default.arn}"
#     }


#     condition {
#       field = "path-pattern"
#       values = ["/*"]
#     }
# }

