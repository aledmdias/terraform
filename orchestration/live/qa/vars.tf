variable "region" {
  description = "The region to create the instances"
  default     = "us-east-1"
}

variable "ambient" {
  description =  "The name of the ambient"
  default     =  "QA"
}

variable "vpc_id" {
  description = "The id of the VPC"
  default     = "vpc-c648eba7"
}

variable "ssh_cidrs" {
  description = "Networks which are allowed to SSH the instances"
  type        = "list"
  default     = ["10.0.0.0/8", "172.16.0.0/16", "172.30.144.0/20", "172.30.250.0/23", "189.114.75.64/27", "189.125.103.160/27"]
}

variable "infraestrutura_bucket" {
  description = "bucket of infraestrutura"
  default     = "infraestrutura"
}

variable "deploy_previous_stage_key" {
  description = "bucket of deploy"
  default     = "deployment/bundles/copper"
}

variable "deploy_stage_key" {
  description = "bucket of deploy"
  default     = "deployment/bundles/bronze"
}

variable "ami" {
  description = "the id of the AMI"
  default     = "ami-34a98a4f"
}

variable "goagent_ami" {
  description = "the id of the AMI used for go agents"
  default     = "ami-62b6be19"
}

variable "web_accelerator_ami" {
  description = "the id of the AMI used for WebAccelerator"
  default     = "ami-50143a2b"
}

variable "service_ami" {
  description = "the id of the AMI used for service"
  default     = "ami-75e9c60e"
}

variable "report_ami" {
  description = "the id of the AMI used for service"
  default     = "ami-88a94ff5"
}

variable "key_name" {
  description = "the key pair name"
  default     = "dimas.kotvan"
}

variable "environment_prefix" {
  description = "The prefix of the hostname"
  default     = "goread-vg"
}

variable "domain" {
  description = "The domain in which will be included the instance"
  default     = "qa.ibacloud.com.br"
}

variable "account_id" {
  description = "Id of AWS account"
  default     = "568869530136"
}
