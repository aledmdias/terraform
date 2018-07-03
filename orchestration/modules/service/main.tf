provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "service" {
  name = "service"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 5000
    to_port         = 6500
    protocol        = "tcp"
    security_groups = ["${var.app_access_security_group_id}"]
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
  vpc_security_group_ids = ["${var.vpc_security_group_ids}", "${aws_security_group.service.id}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-service-%02d.${var.domain}"
  instance_role          = "Service"
  is_blue_green          = true
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}
