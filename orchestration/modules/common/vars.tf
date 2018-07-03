variable "region" {
  description = "The region to create the instances"
}

variable "vpc_id" {
  description = "The id of the VPC"
}

variable "ssh_cidrs" {
  description = "Networks which are allowed to SSH the instances"
  type        = "list"
}

variable "infraestrutura_bucket" {
  description = "bucket of infraestrutura"
}

variable "deploy_bucket" {
  description = "bucket of deploy"
  default     = "goread-devops"
}

variable "deploy_previous_stage_key" {
  description = "bucket of deploy"
}

variable "deploy_stage_key" {
  description = "bucket of deploy"
}

variable "production_backup_bucket" {
  description = "bucket of deploy"
  default     = "iba-infraestrutura"
}

variable "production_backup_bucket_key" {
  description = "key of production's backup"
  default = "backup"
}
