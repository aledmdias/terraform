terraform {
  backend "s3" {
    bucket     = "goread-terraform-state-qa"
    key        = "qa.tf"
    region     = "us-east-1"
    lock_table = "terraform_lock_state"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "common" {
  source                    = "../../modules/common"
  region                    = "us-east-1"
  vpc_id                    = "${var.vpc_id}"
  ssh_cidrs                 = ["${var.ssh_cidrs}"]
  deploy_previous_stage_key = "${var.deploy_previous_stage_key}"
  deploy_stage_key          = "${var.deploy_stage_key}"
  infraestrutura_bucket     = "${var.infraestrutura_bucket}"
}

module "service" {
  source                       = "../../modules/service"
  region                       = "${var.region}"
  vpc_id                       = "${var.vpc_id}"
  instance_count               = 4
  ami                          = "${var.service_ami}"
  instance_type                = "m3.medium"
  vpc_security_group_ids       = ["${module.common.ssh_security_group_id}", "sg-6bc84e04"]       /* added iba-vg-qa-fe security group to have access to Redis */
  app_access_security_group_id = ["${module.web-accelerator.web_accelerator_security_group_id}"]
  available_subnet_ids         = ["subnet-35ed941d", "subnet-8b3e9dea"]

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}

data "aws_iam_server_certificate" "goread_com_br" {
  name_prefix = "star.goread.com.br_2017"
  latest      = true
}

data "aws_iam_server_certificate" "ibacloud_com_br" {
  name        = "star_ibacloud_com_br_2018"
  latest      = true
}

module "web-accelerator" {
  source                     = "../../modules/web-accelerator"
  region                     = "${var.region}"
  vpc_id                     = "${var.vpc_id}"
  instance_count             = 2
  ami                        = "${var.web_accelerator_ami}"
  instance_type              = "m3.medium"
  vpc_security_group_ids     = ["${module.common.ssh_security_group_id}"]
  available_subnet_ids       = ["subnet-35ed941d", "subnet-8b3e9dea"]
  elb_availability_zones     = ["subnet-de3f9cbf", "subnet-8f3f9cee"]
  elb_ssl_certificate_arn    = "${data.aws_iam_server_certificate.goread_com_br.arn}"
  iba_elb_ssl_certificate_arn = "${data.aws_iam_server_certificate.ibacloud_com_br.arn}"
  internal_elb_allowed_cidrs = ["10.0.0.0/8", "172.16.0.0/16", "172.30.158.0/23"]
  terra_server_allowed_cidrs = ["98.142.235.125/32"]
  vivo_server_allowed_cidrs  = ["177.79.239.100/32", "177.79.239.101/32", "177.79.239.102/32", "177.79.239.103/32", "177.79.239.68/32", "177.79.239.69/32", "177.79.239.70/32", "177.79.239.71/32"]
  account_id                 = "${var.account_id}"

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}

module "mongodb" {
  source                   = "../../modules/mongodb"
  region                   = "${var.region}"
  vpc_id                   = "${var.vpc_id}"
  instance_count           = 3
  ami                      = "${var.ami}"
  replica_instance_type    = "m3.medium"
  arbiter_instance_type    = "t2.medium"
  vpc_security_group_ids   = ["${module.common.ssh_security_group_id}"]
  mongo_security_group_ids = ["${module.service.service_security_group_id}", "${module.go-agent.security_group_id}"]
  available_subnet_ids     = ["subnet-2d3e9d4c", "subnet-8b3e9dea"]

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}

module "go-agent" {
  source                      = "../../modules/go-agent"
  region                      = "${var.region}"
  vpc_id                      = "${var.vpc_id}"
  instance_count              = 2
  ami                         = "${var.goagent_ami}"
  instance_type               = "c4.large"
  vpc_security_group_ids      = ["${module.common.ssh_security_group_id}"]
  available_subnet_ids        = ["subnet-35ed941d"]
  go_server_security_group_id = "sg-f2468797"

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}

module "report" {
  source                       = "../../modules/report"
  region                       = "${var.region}"
  vpc_id                       = "${var.vpc_id}"
  instance_count               = 1
  ami                          = "${var.report_ami}"
  instance_type                = "t2.medium"
  db_instance_type             = "db.t2.medium"
  vpc_security_group_ids       = ["${module.common.ssh_security_group_id}"]
  database_access_cidrs        = ["10.0.0.0/8", "172.16.0.0/16", "172.30.144.0/20", "172.30.250.0/23"]
  available_subnet_ids         = ["subnet-35ed941d", "subnet-8b3e9dea"]
  db_username = "report_admin"
  db_password = "nduasgjdas92"

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}

