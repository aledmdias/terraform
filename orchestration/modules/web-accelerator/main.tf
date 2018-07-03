provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "web_accelerator_public" {
  name   = "${var.public_elb_name}"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_accelerator" {
  name = "web_accelerator"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 6081
    to_port         = 6081
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_accelerator_public.id}", "${aws_security_group.terra_broker.id}", "${aws_security_group.vivo_broker.id}"]
  }

  ingress {
    from_port       = 6083
    to_port         = 6083
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_accelerator_internal.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vivo_broker" {
  name = "vivo-broker-public"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.internal_elb_allowed_cidrs}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vivo_server_allowed_cidrs}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "terra_broker" {
  name = "terra-broker-public"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.internal_elb_allowed_cidrs}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.terra_server_allowed_cidrs}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "instance" {
  source                 = "../instance"
  instance_count         = "${var.instance_count}"
  vpc_id                 = "${var.vpc_id}"
  region                 = "${var.region}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}", "${aws_security_group.web_accelerator.id}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-web-accelerator-%02d.${var.domain}"
  instance_role          = "WebAccelerator"
  is_blue_green          = true
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}

resource "aws_elb" "vivo_broker" {
  count = 1

  name    = "elb-vivo-broker-public"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port      = 6081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.elb_ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6081"
    interval            = 10
  }

  security_groups             = ["${aws_security_group.vivo_broker.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "elb-vivo-broker-public"
  }
}


resource "aws_elb" "terra_broker" {
  count = 1

  name    = "elb-terra-broker-public"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port      = 6081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.elb_ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6081"
    interval            = 10
  }

  security_groups             = ["${aws_security_group.terra_broker.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "elb-terra-broker-public"
  }
}


resource "aws_elb" "web_accelerator_public" {
  count = 1

  name    = "${var.public_elb_name}"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port     = 6081
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 6081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.elb_ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6081"
    interval            = 10
  }

  security_groups             = ["${aws_security_group.web_accelerator_public.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "${var.public_elb_name}"
  }
}

resource "aws_elb" "iba_web_accelerator_public" {
  count = 1

  name    = "${var.iba_public_elb_name}"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port     = 6081
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 6081
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.iba_elb_ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6081"
    interval            = 10
  }

  security_groups             = ["${aws_security_group.web_accelerator_public.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 300 # Admin is slow
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "${var.iba_public_elb_name}"
  }
}

/*** INTERNAL ELB *****/

resource "aws_security_group" "web_accelerator_internal" {
  name   = "${var.internal_elb_name}"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.internal_elb_allowed_cidrs}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "iba_web_accelerator_internal" {
  count = 1

  name    = "${var.iba_internal_elb_name}"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port     = 6083
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6083"
    interval            = 10
  }

  internal                    = true
  security_groups             = ["${aws_security_group.web_accelerator_internal.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "${var.iba_internal_elb_name}"
  }
}

resource "aws_elb" "web_accelerator_internal" {
  count = 1

  name    = "${var.internal_elb_name}"
  subnets = "${var.elb_availability_zones}"

  listener {
    instance_port     = 6083
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6083"
    interval            = 10
  }

  internal                    = true
  security_groups             = ["${aws_security_group.web_accelerator_internal.id}"]
  instances                   = ["${module.instance.instance_ids}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30

  tags {
    Name = "${var.internal_elb_name}"
  }
}

/********* Add domains for the instances *******/

data "aws_route53_zone" "hosts" {
  name = "${var.domain}"
}

resource "aws_route53_record" "hosts" {
  count = "${length(var.hosts_for_web_accelerator) > 0 ? length(var.hosts_for_web_accelerator) : 0}"

  zone_id = "${data.aws_route53_zone.hosts.zone_id}"
  type    = "A"
  name    = "${element(var.hosts_for_web_accelerator, count.index)}.${var.domain}"

  alias {
    name                   = "${aws_elb.web_accelerator_internal.dns_name}"
    zone_id                = "${aws_elb.web_accelerator_internal.zone_id}"
    evaluate_target_health = true
  }
}

/******** PERMISSIONS ************/

resource "aws_iam_policy_attachment" "register_desregister_instances_on_elb_goread-policy-attachment" {
  name       = "register_desregister_instances_on_elb_goread-policy-attachment"
  policy_arn = "${aws_iam_policy.register_desregister_instances_on_elb_goread.arn}"
  groups     = []
  users      = []
  roles      = ["${var.iam_instance_profile}"]
}

data "aws_iam_policy_document" "register_desregister_instances_on_elb_goread" {
  statement {
    actions = [
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ]

      /* add elb-iba- balancers to policy */
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.terra_broker.name}",
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.vivo_broker.name}",
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.web_accelerator_public.name}",
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.web_accelerator_internal.name}",
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.iba_web_accelerator_public.name}",
      "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${aws_elb.iba_web_accelerator_internal.name}"
    ]
  }
}

resource "aws_iam_policy" "register_desregister_instances_on_elb_goread" {
  name        = "register_desregister_instances_on_elb_goread"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.register_desregister_instances_on_elb_goread.json}"
}
