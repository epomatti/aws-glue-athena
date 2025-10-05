resource "aws_security_group" "main" {
  name        = "${var.project_name}-allow-all"
  description = "Allow Traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-allow-all"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}
