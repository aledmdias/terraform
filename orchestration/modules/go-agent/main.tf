provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "go_agent" {
  count = "${var.go_server_security_group_id != "" ? 1 : 0}"
  name = "go_agent"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 8154
    to_port         = 8154
    protocol        = "tcp"
    security_groups = ["${var.go_server_security_group_id}"]
    self            = false
  }

  ingress {
    from_port       = 8153
    to_port         = 8153
    protocol        = "tcp"
    security_groups = ["${var.go_server_security_group_id}"]
    self            = false
  }

  ingress {
    from_port       = 5022
    to_port         = 5022
    protocol        = "tcp"
    security_groups = ["${var.go_server_security_group_id}"]
    self            = false
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
  
  vpc_security_group_ids = ["${concat(var.vpc_security_group_ids, aws_security_group.go_agent.*.id)}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-goagent-%02d.${var.domain}"
  instance_role          = "GoAgent"
  is_blue_green          = false
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}
