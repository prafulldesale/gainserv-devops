resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-alb"
  }

  # Create the replacement before removing the existing security group.
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "To pods on the app port (target-type ip)"
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
}

# EKS nodes (pods share it with the VPC CNI): app port from the ALB only, nodes talk to each other, any egress.
# Karpenter picks it up through the discovery tag; the EKS-managed cluster SG is attached too for control-plane traffic
resource "aws_security_group" "node" {
  name_prefix = "${var.name_prefix}-node-"
  description = "EKS worker node security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name                     = "${var.name_prefix}-node"
    "karpenter.sh/discovery" = var.cluster_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "node_from_alb" {
  security_group_id            = aws_security_group.node.id
  description                  = "Allow application traffic from ALB"
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  security_group_id            = aws_security_group.node.id
  description                  = "Allow communication between worker nodes"
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.node.id
  description       = "Outbound via NAT / VPC (image pulls, AWS APIs)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
