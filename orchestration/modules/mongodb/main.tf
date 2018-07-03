provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "mongodb" {
  name = "mongodb"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = ["189.114.75.64/27", "189.125.103.160/27", "10.0.0.0/8"]
    security_groups = ["${var.mongo_security_group_ids}"]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "instance-replica" {
  source                 = "../instance"
  instance_count         = "${var.instance_count - 1}"
  vpc_id                 = "${var.vpc_id}"
  region                 = "${var.region}"
  ami                    = "${var.ami}"
  instance_type          = "${var.replica_instance_type}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}", "${aws_security_group.mongodb.id}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-mongodb-%02d.${var.domain}"
  instance_role          = "MongoDBReplica"
  is_blue_green          = false
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}

module "instance-arbiter" {
  source                 = "../instance"
  instance_count         = "1"
  vpc_id                 = "${var.vpc_id}"
  region                 = "${var.region}"
  ami                    = "${var.ami}"
  instance_type          = "${var.arbiter_instance_type}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}", "${aws_security_group.mongodb.id}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-arbiter-%02d.${var.domain}"
  instance_role          = "MongoDBArbiter"
  is_blue_green          = false
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}
