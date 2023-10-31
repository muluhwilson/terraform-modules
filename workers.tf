resource "aws_eks_node_group" "eks-worker-ng" {
    cluster_name = "${aws_eks_cluster.eks-cluster.name}"
    node_group_name = "${format("%s-%s-%s-ng",var.cluster_name, var.tag_service, var.tag_environment)}"
    node_role_arn = "${aws_iam_role.eks-worker-role.arn}"
    subnet_ids = ["${aws_subnet.eks-private.*.id}"]
    disk_size = "${var.eks_ebsvol_size}"
    instance_types = ["${var.eks_instance_type}"]
    
    scaling_config {
        desired_size = "${var.desired_worker_instances}"
        max_size = "${var.max_worker_instances}"
        min_size = "${var.min_worker_instances}"
    }
    remote_access {
        ec2_ssh_key = "${var.ec2_ssh_key}"
        source_security_group_ids = ["${var.ec2_bastion_sg_id}"]
    }

    tags {
        "Name" = "${format("%s-%s-%s-ng",var.cluster_name, var.tag_service, var.tag_environment)}"
        "service" = "${var.tag_service}"
        "environment" = "${var.tag_environment}"
        "provisioned" = "terraform"
    }

    depends_on = [
        "aws_iam_role_policy_attachment.EKS-WorkerNode-Policy",
        "aws_iam_role_policy_attachment.EKS-CNI-Policy",
        "aws_iam_role_policy_attachment.EC2-ContainerRegistry-ReadOnly",
        "aws_iam_role_policy_attachment.EKS-Worker-CloudWatchPolicy"
    ]

}

output "remote_access_security_group_id" {
    value = "${aws_eks_node_group.eks-worker-ng.resources}"
}