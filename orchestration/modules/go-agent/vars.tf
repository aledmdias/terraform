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
  default   = "goread-agent"
}

variable "vpc_security_group_ids" {
  description = "the security groups which the instance should use"
  type = "list"
}

variable "available_subnet_ids" {
  description = "the security groups which the instance should use"
  type = "list"
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

variable "start_stop" {
  description = "if it should have the start_stop tags"
}

variable "domain" {
  description = "The domain in which will be included the instance"
}

variable "go_server_security_group_id" {
  description = "security group id of the go server"
  default = ""
}
