locals {
    cw_role_binding = << CLOUDWATCHROLEBINDING

# create amazon-cloudwatch namespace
apiVersion: v1
kind: Namespace
metadata:
    name: amazon-cloudwatch
    labels:
        name: amazon-cloudwatch
---

#create cwagent service account
apiVersion: v1
kind: ServiceAccount
metadata:
    name: cloudwatch-agent
    namespace: amazon-cloudwatch
---

#Role which gives permissions to collect metrics and logs
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io / v1
metadata:
    name: cloudwatch-agent-role
rules:
    - apiGroups: [""]
      resources: ["pods", "nodes", "endpoints"]
      verbs: ["list", "watch"]
    - apiGroups: ["apps"]
      resources: ["replicasets"]
      verbs: ["list", "watch"]
    - apiGroups: ["batch"]
      resources: ["jobs"]
      verbs: ["list", "watch"]
    - apiGroups: [""]
      resources: ["nodes/proxy"]
      verbs: ["get"]
    - apiGroups: [""]
      resources: ["nodes/stats", "configmaps", "events"]
      verbs: ["create"]
    - apiGroups: [""]
      resources: ["configmaps"] resourceNames: ["cwagent-clusterleader"]
      verbs: ["get", "update"]
---

#Role Binding to svc account
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io / v1
metadata:
name: cloudwatch-agent-role-binding
subjects:
    - kind: ServiceAccount
      name: cloudwatch-agent
      namespace: amazon-cloudwatch
roleRef:
    kind: ClusterRole
    name: cloudwatch-agent-role
    apiGroup: rbac.authorization.k8s.io
---

#create configmap for cwagent config(Region for endpoint should be changed accordingly)
apiVersion: v1
data: cwagentconfig.json: | 
    {
        "logs": {
            "metrics_collected": {
                "kubernetes": {
                    "metrics_collection_interval": 60
                }
            },
            "force_flush_interval": 5,
            "endpoint_override": "logs.${var.region}.amazonaws.com"
        }
    }
kind: ConfigMap
metadata:
    name: cwagentconfig
    namespace: amazon-cloudwatch

CLOUDWATCHROLEBINDING

}

resource "local_file" "cw_role_binding" {
    content = "${local.cw_role_binding}"
    filename = "${path.module}/cloudwatch_role_binding.yaml"
}

resource "null_resource" "apply_cw_role_binding" {
    # ...

    provisioner "local-exec" {
        command = "kubectl apply -f cloudwatch_role_binding.yaml && kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml && kubectl create configmap cluster-info --from-literal=cluster.name=${var.cluster_name} --from-literal=logs.region=${var.region} -n amazon-cloudwatch && kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluentd/fluentd.yaml"
        working_dir = "${path.module}"
    }
    depends_on = ["local_file.kubeconfig", "local_file.cw_role_binding", "aws_eks_node_group.eks-worker-ng", "null_resource.copy_kubeconfig_to_localpath"]