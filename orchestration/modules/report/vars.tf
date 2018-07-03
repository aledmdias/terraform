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
  default     = "goread-report"
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
 * Variables unique to report
 */
variable "db_instance_type" {
  description = "the type of the db instance"
}

variable "db_username" {
  description = "the username of the db instance"
}

variable "db_password" {
  description = "the password of the db instance"
}

variable "database_access_cidrs" {
  description = "ips which will access the database"
  type        = "list"
}
