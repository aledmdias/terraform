provider "aws" {
  region = "${var.region}"
}

/** EC2 INSTANCE **/

resource "aws_security_group" "goread_report" {
  name = "goread_report"

  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 80 
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  vpc_security_group_ids = ["${var.vpc_security_group_ids}", "${aws_security_group.goread_report.id}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  available_subnet_ids   = ["${var.available_subnet_ids}"]
  key_name               = "${var.key_name}"
  domain                 = "${var.domain}"
  instance_name_fmt      = "${var.environment_prefix}-report-%02d.${var.domain}"
  instance_role          = "Report"
  is_blue_green          = false
  start_stop             = "${var.start_stop}"
  ambient                = "${var.ambient}"
}

/** DATABASE **/

resource "aws_db_subnet_group" "report_database" {
  name       = "report_database_subnet_group"
  subnet_ids = ["subnet-35ed941d", "subnet-8b3e9dea"]
}

resource "aws_security_group" "report_database" {
  name   = "report_database"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.goread_report.id}"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["${var.database_access_cidrs}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "report_database" {
  allocated_storage = "20"
  auto_minor_version_upgrade = "true"
  availability_zone = "us-east-1a"
  backup_retention_period = "7"
  backup_window = "08:50-09:20"
  db_subnet_group_name = "${aws_db_subnet_group.report_database.id}"
  engine = "postgres"
  engine_version = "9.6.6"
  identifier = "report-database"
  instance_class = "${var.db_instance_type}"
  license_model = "postgresql-license"
  maintenance_window = "sun:08:08-sun:08:38"
  multi_az = "false"
  publicly_accessible = "false"
  replicate_source_db = ""
  skip_final_snapshot = "true"
  storage_encrypted = "false"
  storage_type = "gp2"
  username = "${var.db_username}"
  password = "${var.db_password}"

  vpc_security_group_ids = ["${aws_security_group.report_database.id}"]

  tags = {
    workload-type = "other"
  }
}



