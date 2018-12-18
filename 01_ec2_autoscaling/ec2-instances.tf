data "template_file" "init" {
  template = "${file("${path.module}/scripts/user-script.sh")}"
}

resource "aws_launch_configuration" "as_conf" {
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.admin.key_name}"

  user_data = "${data.template_file.init.rendered}"

  security_groups = [
    "${aws_security_group.http_server_public.id}",
    "${aws_security_group.allow_ssh_ip.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.ec2_default.name}"

  associate_public_ip_address = "false"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "application" {
  name                 = "ASG"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"

  vpc_zone_identifier = ["${aws_subnet.private_a.id}", "${aws_subnet.private_b.id}", "${aws_subnet.private_c.id}"]

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  load_balancers = ["${aws_elb.default-elb.name}"]

  // "TerminationPolicyTypes": [
  //      "ClosestToNextInstanceHour",
  //      "Default",
  //      "NewestInstance",
  //      "OldestInstance",
  //      "OldestLaunchConfiguration"
  //  ]

  termination_policies = ["OldestInstance"]

  lifecycle {
    create_before_destroy = true
  }

  # Tag all instances
  tag {
    key                 = "Name"
    value               = "EC2-sample-service"
    propagate_at_launch = true
  }
}
