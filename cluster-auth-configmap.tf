locals { config_map_aws_auth = << CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
    name: aws-auth
    namespace: kube-system
data:
    mapRoles: |
        - rolearn: ${aws_iam_role.eks-worker-role.arn}
          username: system: node: { { EC2PrivateDNSName } }
          groups:
            - system: bootstrappers
            - system: nodes
        - rolearn: arn: aws: iam::$ { var.amazon_account_id }: role / EC2_General
          username: EC2_General
          groups:
            - system: masters
        mapUsers: |
            - userarn: arn: aws: iam::$ { var.amazon_account_id }: user / $ { var.tag_environment == "prod-uw2" ? "leela.manne" : "l.manne@partner.samsung.com" }
              username: $ { var.tag_environment == "prod-uw2" ? "leela.manne" : "l.manne@partner.samsung.com" }
              groups:
                - system: masters
            - userarn: arn: aws: iam::$ { var.amazon_account_id }: user / $ { var.tag_environment == "prod-uw2" ? "s.nekkalapud" : "s.nekkalapud@partner.samsung.com" }
              username: $ { var.tag_environment == "prod-uw2" ? "s.nekkalapud" : "s.nekkalapud@partner.samsung.com" }
              groups:
                - system: masters
            - userarn: arn: aws: iam::$ { var.amazon_account_id }: user / $ { var.tag_environment == "prod-uw2" ? "ramesh.vasudevan" : "ramesh.vasudevan@samsung.com" }
              username: $ { var.tag_environment == "prod-uw2" ? "ramesh.vasudevan" : "ramesh.vasudevan@samsung.com" }
              groups:
                - system: masters
CONFIGMAPAWSAUTH

}

output "config_map_aws_auth" {
    value = "${local.config_map_aws_auth}"
}

resource "local_file" "config_map_aws_auth" {
    content = "${local.config_map_aws_auth}"
    filename = "${path.module}/config_map_aws_auth.yaml"
} 

resource "null_resource" "apply_config_map" {
    # ...

    provisioner "local-exec" {
        command = "kubectl apply -f config_map_aws_auth.yaml && kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml"
        working_dir = "${path.module}"
    }
    depends_on = ["local_file.kubeconfig", "aws_eks_node_group.eks-worker-ng", "null_resource.copy_kubeconfig_to_localpath"]
}