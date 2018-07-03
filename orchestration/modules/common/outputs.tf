output "ssh_security_group_id" {
  value = "${aws_security_group.common_ssh.id}"
}
