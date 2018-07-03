variable "region" {
  description = "The region to create the instances"
  default     = "sa-east-1"
}

variable "ambient" {
  description =  "The name of the ambient"
  default     =  "Production"
}

variable "vpc_id" {
  description = "The id of the VPC"
  default     = "vpc-34a22f5d"
}

variable "ssh_cidrs" {
  description = "Networks which are allowed to SSH the instances"
  type        = "list"
  default     = ["10.0.0.0/8", "172.16.0.0/16", "172.16.23.200/32", "172.30.144.0/20", "192.168.253.0/24", "192.168.254.0/24" ]
  /* 
   * TODO: document the ips
   * On iba there were security groups which had access to SSH the machines:
   * 
   * sg-8dd5cce1 - iba-zabbix-proxy
   * sg-05759d60 - iba-sp-goagent
   * sg-39352955 - NATSG -> only on jobs - not using right now
   */
}

variable "infraestrutura_bucket" {
  description = "bucket of infraestrutura"
  default     = "iba-infraestrutura"
}

variable "deploy_previous_stage_key" {
  description = "bucket of deploy"
  default     = "deployment/bundles/bronze"
}

variable "deploy_stage_key" {
  description = "bucket of deploy"
  default     = "deployment/bundles/gold"
}

variable "goagent_ami" {
  description = "the id of the AMI used for go agents"
  default     = "ami-12d8b57e"
}

variable "web_accelerator_ami" {
  description = "the id of the AMI used for WebAccelerator"
  default     = "ami-60f6800c"
}

variable "service_ami" {
  description = "the id of the AMI used for service"
  default     = "ami-09f68065"
}

variable "key_name" {
  description = "the key pair name"
  default     = "dimas.kotvan"
}

variable "environment_prefix" {
  description = "The prefix of the hostname"
  default     = "goread-sp"
}

variable "domain" {
  description = "The domain in which will be included the instance"
  default     = "ibacloud.com.br"
}

variable "account_id" {
  description = "Id of AWS account"
  default     = "518944852004"
}
