/*
 * Variables shared by all modules 
 * TODO: DRY it
 */
variable "region" {
  description = "The region to create the instances"
}

variable "ambient" {
  description =  "The name of the ambient"
}

variable "vpc_id" {
  description = "The id of the VPC"
}

variable "instance_count" {
  description = "the number of instances you want to create"
}

variable "ami" {
  description = "the id of the AMI"
}

variable "iam_instance_profile" {
  description = "the profile to apply the agent role"
  default     = "goread-web-accelerator"
}

variable "vpc_security_group_ids" {
  description = "the security groups which the instance should use"
  type        = "list"
}

variable "available_subnet_ids" {
  description = "the security groups which the instance should use"
  type        = "list"
}

variable "instance_type" {
  description = "the type of the instance"
}

variable "key_name" {
  description = "the key pair name"
}

variable "environment_prefix" {
  description = "The prefix of the hostname"
}

variable "domain" {
  description = "The domain in which will be included the instance"
}

variable "start_stop" {
  description = "if it should have the start_stop tags"
}

/*
 * Variable exclusive to WebAccelerators
 */
variable "public_elb_name" {
  description = "The name of the public ELB"
  default     = "elb-goread-accelerator-public"
}

variable "internal_elb_name" {
  description = "The name of the internal ELB"
  default     = "elb-goread-accelerator-internal"
}

variable "iba_public_elb_name" {
  description = "The name of the public ELB with iba domain"
  default     = "elb-iba-accelerator-public"
}

variable "iba_internal_elb_name" {
  description = "The name of the internal ELB with iba domain"
  default     = "elb-iba-accelerator-internal"
}

variable "elb_availability_zones" {
  description = "The subnte_ids for the elb availability_zones"
  type        = "list"
}

variable "elb_ssl_certificate_arn" {
  description = "The ARN for the certificate"
}

variable "iba_elb_ssl_certificate_arn" {
  description = "The ARN for the certificate for old iba domain"
}

variable "hosts_for_web_accelerator" {
  description = "list of hosts in which the ELB will response. Needs to be all in the domain specified on the variable domain. Example if var.domain is qa.goread.com.br, the value here should be service and it will be registered as service.qa.goread.com.br"
  type = "list"
  default = ["content-delivery-internal"]
}

variable "internal_elb_allowed_cidrs" {
  description = "CIDRs which are allowed to use the internal address"
  type = "list"
}

variable "vivo_server_allowed_cidrs" {
  description = "CIDRs from Vivo Servers"
  type = "list"
}

variable "terra_server_allowed_cidrs" {
  description = "CIDRs from Terra Servers"
  type = "list"
}

variable "account_id" {
  description = "Id of AWS account"
}
