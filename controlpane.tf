resource "aws_eks_cluster" "eks-cluster" {
    name = "${format("%s-%s-%s",var.cluster_name, var.tag_service, var.tag_environment)}"
    role_arn = "${aws_iam_role.eks-cluster-role.arn}"
    enabled_cluster_log_types = "${var.cluster_enabled_log_types}"
    version = "${var.cluster_version}"

    vpc_config {
        security_group_ids = ["${var.vpc_common_sg_id}"]
        subnet_ids = ["${aws_subnet.eks-private.*.id}", "${aws_subnet.eks-public.*.id}"]
        endpoint_private_access = "${var.cluster_endpoint_private_access}"
        endpoint_public_access = "${var.cluster_endpoint_public_access}"
        public_access_cidrs = "${var.cluster_endpoint_public_access_cidrs}"
    }
    tags {
        "Name" = "${format("%s-%s-%s",var.cluster_name, var.tag_service, var.tag_environment)}"
        "service" = "${var.tag_service}" "environment" = "${var.tag_environment}" "provisioned" = "terraform"
    }

    depends_on = [
        "aws_iam_role_policy_attachment.EKS-cluster-AmazonEKSClusterPolicy",
        "aws_iam_role_policy_attachment.EKS-cluster-AmazonEKSServicePolicy",
        "aws_cloudwatch_log_group.eks-log-group"
    ]
}

resource "aws_cloudwatch_log_group" "eks-log-group" {
    name = "/aws/eks/${var.cluster_name}/cluster"
    retention_in_days = 30
}