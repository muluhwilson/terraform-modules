locals {
    kubeconfig = << KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks-cluster.certificate_authority .0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: ${var.cluster_name}-${var.tag_environment}
current-context: ${var.cluster_name}-${var.tag_environment}
kind: Config
preferences:{}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${format("%s-%s-%s",var.cluster_name, var.tag_service, var.tag_environment)}"
      env:
      - name: AWS_PROFILE
        value: ${var.profile}
KUBECONFIG
}


output "kubeconfig" {
    value = "${local.kubeconfig}"
}

resource "local_file" "kubeconfig"
{
    content = "${local.kubeconfig}"
    filename = "${path.module}/kubeconfig"
}

resource "null_resource" "copy_kubeconfig_to_localpath" {
    # ...
    
    provisioner "local-exec" {
        command = "cp kubeconfig ${var.kubeconfig_path}"
        working_dir = "${path.module}"
    }
    depends_on = ["local_file.kubeconfig"]
}