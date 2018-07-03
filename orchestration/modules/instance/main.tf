provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "instance" {
  count                       = "${var.instance_count}"
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
  iam_instance_profile        = "${var.iam_instance_profile}"
  subnet_id                   = "${element(var.available_subnet_ids, count.index % length(var.available_subnet_ids))}"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  associate_public_ip_address = false

  tags {
    Name     = "${format(var.instance_name_fmt, count.index + 1)}"
    Platform = "GoRead"
    Role     = "${var.instance_role}"
    Pool     = "${var.is_blue_green ? element(var.pools, count.index % length(var.pools)) : ""}"
    start    = "${var.start_stop ? "07" : ""}"
    stop     = "${var.start_stop ? "20" : ""}"
    Ambient  = "${var.ambient}"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo sh -c 'echo "127.0.0.1 ${format(var.instance_name_fmt, count.index + 1)}" >> /etc/hosts'
              sudo hostname "${format(var.instance_name_fmt, count.index + 1)}"
              sudo sh -c 'echo "${format(var.instance_name_fmt, count.index + 1)}" > /etc/hostname'
              /usr/local/bin/authorized_keys
              EOF
}

data "aws_route53_zone" "instance" {
  name = "${var.domain}"
}

resource "aws_route53_record" "instance" {
  count = "${var.domain != "localdomain" ? var.instance_count : 0}"

  zone_id = "${data.aws_route53_zone.instance.zone_id}"
  type    = "A"
  ttl     = "300"
  name    = "${element(aws_instance.instance.*.tags.Name, count.index)}"
  records = ["${element(aws_instance.instance.*.private_ip, count.index)}"]
}
