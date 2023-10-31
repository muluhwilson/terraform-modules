resource "aws_security_group_rule" "eks-worker-node-self-inngress" {
  count                    = 1
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id ")
  source_security_group_id = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id ")
  to_port                  = 65535
  type                     = "ingress"
  description              = "allows workers to commuincate with each other for the purpose of sendinng logs to cloudwatch"
  depends_on               = ["aws_eks_node_group.eks-worker-ng"]
}

resource "aws_security_group_rule" "eks-worker-node-egress-cwinterface-https" {
  // count = "${length(aws_eks_node_group.eks-worker-ng.resources)}"
  count                    = 1
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id")
  source_security_group_id = var.vpc_endpoint_network_interface_sg_id
  to_port                  = 443
  type                     = "egress"
  description              = "sends logs to cloudwatch via interface endpoints"
  depends_on               = ["aws_eks_node_group.eks-worker-ng"]
}

resource "aws_security_group_rule" "eks-worker-node-egress-cwinterface-http" {
  // count = "${length(aws_eks_node_group.eks-worker-ng.resources)}"
  count                    = 1
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id")
  source_security_group_id = var.vpc_endpoint_network_interface_sg_id
  to_port                  = 80
  type                     = "egress"
  description              = "sends logs to cloudwatch via interface endpoints"
  depends_on               = ["aws_eks_node_group.eks-worker-ng"]
}

resource "aws_security_group_rule" "igress-cwinterface-http" {
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = var.vpc_endpoint_network_interface_sg_id
  source_security_group_id = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id")
  to_port                  = 80
  type                     = "ingress"
  description              = "Inbound for interface sg from eks remote access sg"
  depends_on               = ["aws_eks_node_group.eks-worker-ng"]
}

resource "aws_security_group_rule" "igress-cwinterface-https" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.vpc_endpoint_network_interface_sg_id
  source_security_group_id = lookup(aws_eks_node_group.eks-worker-ng.resources[count.index], "remote_access_security_group_id")
  to_port                  = 443
  type                     = "ingress"
  description              = "Inbound for interface sg from eks remote access sg"
  depends_on               = ["aws_eks_node_group.eks-worker-ng"]
}

resource "aws_security_group_rule" "ingress-rds-sg" {
  from_port                = 43306
  protocol                 = "tcp"
  security_group_id        = var.sg_rds_id
  source_security_group_id = lookup(aws_eks_cluster.eks-cluster.vpc_config[count.index], "cluster_security_group_id")
  to_port                  = 43306
  type                     = "ingress"
  description              = "Inbound for RDS from EKS worker nodes"
}

resource "aws_security_group_rule" "ingress-redis-sg" {
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = var.elasticache_security_group_id
  source_security_group_id = lookup(aws_eks_cluster.eks-cluster.vpc_config[count.index], "cluster_security_group_id")
  to_port                  = 6379
  type                     = "ingress"
  description              = "Inbound for Redis from worker nodes"
}

resource "aws_security_group_rule" "ingress-emr-sg" {
  from_port                = 8765
  protocol                 = "tcp"
  security_group_id        = var.emr_private_master_sg_id
  source_security_group_id = lookup(aws_eks_cluster.eks-cluster.vpc_config[count.index], "cluster_security_group_id")
  to_port                  = 8765
  type                     = "ingress"
  description              = "Inbound for EMR from worker nodes"
}

resource "aws_security_group_rule" "ingress-elk-sg" {
  from_port                = 9200
  protocol                 = "tcp"
  security_group_id        = var.crp_elk_sg_id
  source_security_group_id = lookup(aws_eks_cluster.eks-cluster.vpc_config[count.index], "cluster_security_group_id")
  to_port                  = 9200
  type                     = "ingress"
  description              = "Inbound for ELK from worker nodes"
}
