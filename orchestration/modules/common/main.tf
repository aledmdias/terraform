provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "common_ssh" {
  name        = "common-ssh"
  description = "Security group to open SSH ports"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5022
    to_port     = 5022
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidrs}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy_attachment" "get_packages_for_deploy-policy-attachment" {
  name       = "get_packages_for_deploy-policy-attachment"
  policy_arn = "${aws_iam_policy.get_packages_for_deploy.arn}"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_service.name}", "${aws_iam_role.goread_web_accelerator.name}"]
}

resource "aws_iam_policy_attachment" "upload_apps_logs-policy-attachment" {
  name       = "upload_apps_logs-policy-attachment"
  policy_arn = "${aws_iam_policy.upload_apps_logs.arn}"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_service.name}"]
}

resource "aws_iam_policy_attachment" "get_deploy_user_authorized_keys-policy-attachment" {
  name       = "get_deploy_user_authorized_keys-policy-attachment"
  policy_arn = "${aws_iam_policy.get_deploy_user_authorized_keys.arn}"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_service.name}", "${aws_iam_role.goread_web_accelerator.name}", "${aws_iam_role.goread_agent.name}", "${aws_iam_role.goread_report.name}"]
}

resource "aws_iam_policy_attachment" "get_ec2_user_authorized_keys-policy-attachment" {
  name       = "get_ec2_user_authorized_keys-policy-attachment"
  policy_arn = "${aws_iam_policy.get_ec2_user_authorized_keys.arn}"
  users      = []
  roles      = ["${aws_iam_role.goread_agent.name}", "${aws_iam_role.goread_service.name}", "${aws_iam_role.goread_web_accelerator.name}", "${aws_iam_role.goread_mongodb.name}"]
}

resource "aws_iam_policy_attachment" "can_promote_packages-policy-attachment" {
  name       = "can_promote_packages-policy-attachment"
  policy_arn = "${aws_iam_policy.can_promote_packages.arn}"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_agent.name}"]
}

resource "aws_iam_policy_attachment" "download_database_backups-policy-attachment" {
  name       = "download_database_backups-policy-attachment"
  policy_arn = "${aws_iam_policy.download_database_backups.arn}"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_report.name}"]
}

resource "aws_iam_policy_attachment" "amazon_ec2_read_only_access-policy-attachment" {
  name       = "can_promote_packages-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  groups     = []
  users      = []
  roles      = ["${aws_iam_role.goread_agent.name}"]
}

data "aws_iam_policy_document" "get_packages_for_deploy" {
  statement {
    actions = ["s3:Get*", "s3:List*"]
    resources = [
      "arn:aws:s3:::${var.deploy_bucket}/${var.deploy_stage_key}/*",
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.deploy_bucket}",
    ]
  }
}

resource "aws_iam_policy" "get_packages_for_deploy" {
  name        = "get_packages_for_deploy"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.get_packages_for_deploy.json}"
}

data "aws_iam_policy_document" "upload_apps_logs" {
  statement {
    actions = ["s3:Get*", "s3:List*", "s3:Put*"]
    resources = [
      "arn:aws:s3:::${var.infraestrutura_bucket}/log/*",
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.deploy_bucket}",
    ]
  }
}

resource "aws_iam_policy" "upload_apps_logs" {
  name        = "upload_apps_logs"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.upload_apps_logs.json}"
}

data "aws_iam_policy_document" "get_deploy_user_authorized_keys" {
  statement {
    actions = ["s3:Get*"]
    resources = [
      "arn:aws:s3:::${var.infraestrutura_bucket}/rsa/deploy/*"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.infraestrutura_bucket}"
    ]
  }
}

resource "aws_iam_policy" "get_deploy_user_authorized_keys" {
  name        = "get_deploy_user_authorized_keys"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.get_deploy_user_authorized_keys.json}"
}

data "aws_iam_policy_document" "get_ec2_user_authorized_keys" {
  statement {
    actions = ["s3:Get*"]
    resources = [
      "arn:aws:s3:::${var.infraestrutura_bucket}/rsa/ec2-user/authorized_keys"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.infraestrutura_bucket}"
    ]
  }
}

resource "aws_iam_policy" "get_ec2_user_authorized_keys" {
  name        = "get_ec2_user_authorized_keys"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.get_ec2_user_authorized_keys.json}"
}

data "aws_iam_policy_document" "can_promote_packages" {
  statement {
    actions = ["s3:Get*", "s3:List*", "s3:Put*"]
    resources = [
      "arn:aws:s3:::${var.deploy_bucket}/${var.deploy_previous_stage_key}/*",
      "arn:aws:s3:::${var.deploy_bucket}/${var.deploy_stage_key}/*"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.deploy_bucket}"
    ]
  }
}

resource "aws_iam_policy" "can_promote_packages" {
  name        = "can_promote_packages"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.can_promote_packages.json}"
}

data "aws_iam_policy_document" "download_database_backups" {
  statement {
    actions = ["s3:Get*", "s3:List*"]
    resources = [
      "arn:aws:s3:::${var.production_backup_bucket}/${var.production_backup_bucket_key}/*"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.production_backup_bucket}"
    ]
  }
}

resource "aws_iam_policy" "download_database_backups" {
  name        = "download_database_backups"
  path        = "/"
  description = ""

  policy = "${data.aws_iam_policy_document.download_database_backups.json}"
}

resource "aws_iam_role" "goread_agent" {
  name = "goread-agent"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "goread_mongodb" {
  name = "goread-mongodb"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "goread_service" {
  name = "goread-service"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "goread_web_accelerator" {
  name = "goread-web-accelerator"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "goread_report" {
  name = "goread-report"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "goread_agent" {
  name = "goread-agent"
  path = "/"
  role = "${aws_iam_role.goread_agent.name}"
}

resource "aws_iam_instance_profile" "goread_mongodb" {
  name = "goread-mongodb"
  path = "/"
  role = "${aws_iam_role.goread_mongodb.name}"
}

resource "aws_iam_instance_profile" "goread_service" {
  name = "goread-service"
  path = "/"
  role = "${aws_iam_role.goread_service.name}"
}

resource "aws_iam_instance_profile" "goread_web_accelerator" {
  name = "goread-web-accelerator"
  path = "/"
  role = "${aws_iam_role.goread_web_accelerator.name}"
}

resource "aws_iam_instance_profile" "goread_report" {
  name = "goread-report"
  path = "/"
  role = "${aws_iam_role.goread_report.name}"
}
