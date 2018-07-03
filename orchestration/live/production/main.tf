terraform {
  backend "s3" {
    bucket     = "goread-terraform-state"
    key        = "production.tf"
    region     = "sa-east-1"
    lock_table = "terraform_lock_state"
  }
}

provider "aws" {
  region = "${var.region}"
}

module "common" {
  source                    = "../../modules/common"
  region                    = "${var.region}"
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
  instance_type                = "m3.large"
  vpc_security_group_ids       = ["${module.common.ssh_security_group_id}", "sg-f8f9e79a"]       /* added iba-sp-fe security group to have access to Redis */
  app_access_security_group_id = ["${module.web-accelerator.web_accelerator_security_group_id}"]
  available_subnet_ids         = ["subnet-64b23f0d", "subnet-0ea22f67"]

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = false
  ambient            = "${var.ambient}"
}

data "aws_iam_server_certificate" "goread_com_br" {
  name   = "star.goread.com.br"
  latest = true
}

data "aws_iam_server_certificate" "iba_com_br" {
  name        = "iba.com.br"
  latest      = true
}

module "web-accelerator" {
  source                     = "../../modules/web-accelerator"
  region                     = "${var.region}"
  vpc_id                     = "${var.vpc_id}"
  instance_count             = 2
  ami                        = "${var.web_accelerator_ami}"
  instance_type              = "m3.large"
  vpc_security_group_ids     = ["${module.common.ssh_security_group_id}"]
  available_subnet_ids       = ["subnet-64b23f0d", "subnet-0ea22f67"]
  elb_availability_zones     = ["subnet-60b23f09", "subnet-0aa22f63"]
  elb_ssl_certificate_arn    = "${data.aws_iam_server_certificate.goread_com_br.arn}"
  iba_elb_ssl_certificate_arn    = "${data.aws_iam_server_certificate.iba_com_br.arn}"
  internal_elb_allowed_cidrs = ["10.0.0.0/8", "172.16.0.0/16", "172.30.144.0/20", "172.20.3.11/32"]
  terra_server_allowed_cidrs = ["10.0.0.0/8", "172.0.0.0/8", "177.72.248.101/32", "54.232.197.122/32", "177.72.249.101/32", "98.142.235.192/27", "98.142.235.125/32", "177.72.248.104/32"]
  vivo_server_allowed_cidrs = ["177.79.239.100/32", "177.79.239.102/32", "177.79.239.103/32", "177.79.239.68/32", "177.79.239.69/32", "177.79.239.70/32", "177.79.239.71/32"]

  account_id                 = "${var.account_id}"

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = false
  ambient            = "${var.ambient}"
}

module "go-agent" {
  source                      = "../../modules/go-agent"
  region                      = "${var.region}"
  vpc_id                      = "${var.vpc_id}"
  instance_count              = 1
  ami                         = "${var.goagent_ami}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${module.common.ssh_security_group_id}", "sg-05759d60"]
  available_subnet_ids        = ["subnet-0ea22f67"]
  go_server_security_group_id = "sg-f2468797"

  key_name           = "${var.key_name}"
  environment_prefix = "${var.environment_prefix}"
  domain             = "${var.domain}"
  start_stop         = true
  ambient            = "${var.ambient}"
}
