### The version of ingress controller image need to be checked regularly before creating cluster

locals {
    INGRESS_CONTROLLER_DEPLOY = << INGRESSCONTROLLER


# Application Load Balancer(ALB) Ingress Controller Deployment Manifest.
# This manifest details sensible defaults for deploying an ALB Ingress Controller.
#GitHub: https: //github.com/kubernetes-sigs/aws-alb-ingress-controller
apiVersion: apps/v1
kind: Deployment
metadata:
    labels:
        app.kubernetes.io/name: alb-ingress-controller
    name: alb-ingress-controller 
    # Namespace the ALB Ingress Controller should run in. Does not impact which 
    # namespaces it's able to resolve ingress resource for. For limiting ingress 
    # namespace scope, see --watch-namespace.
    namespace: kube-system
spec:
    selector:
        matchLabels:
            app.kubernetes.io/name: alb-ingress-controller
        template:
            metadata:
                labels:
                    app.kubernetes.io/name: alb-ingress-controller
            spec:
                containers:
                    - name: alb-ingress-controller
                      args: 
                        # Limit the namespace where this ALB Ingress Controller deployment will 
                        # resolve ingress resources. If left commented, all namespaces are used. 
                        # - --watch-namespace=your-k8s-namespace 

                        # Setting the ingress-class flag below ensures that only ingress resources with the 
                        # annotation kubernetes.io/ingress.class: "alb" are respected by the controller. You may 
                        # choose any class you'd like for this controller to respect. - --ingress-class=alb 
                        
                        # REQUIRED 
                        # Name of your cluster. Used when naming resources created 
                        # by the ALB Ingress Controller, providing distinction between 
                        # clusters. - --cluster-name=${var.cluster_name}-${var.tag_service}-${var.tag_environment} 
                        
                        # AWS VPC ID this ingress controller will use to create AWS resources. 
                        # If unspecified, it will be discovered from ec2metadata. 
                        # - --aws-vpc-id=vpc-xxxxxx 
                        
                        # AWS region this ingress controller will operate in. 
                        # If unspecified, it will be discovered from ec2metadata. 
                        # List of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html
                        #vpc_region 
                        # - --aws-region=us-west-1 
                        
                        # Enables logging on all outbound requests sent to the AWS API. 
                        # If logging is desired, set to true. 
                        # - --aws-api-debug 
                        # Maximum number of times to retry the aws calls. 
                        # defaults to 10. 
                        # - --aws-max-retries=10 
                    # env: 
                        # AWS key id for authenticating with the AWS API. 
                        # This is only here for examples. It's recommended you instead use 
                        # a project like kube2iam for granting access. 
                        #- name: AWS_ACCESS_KEY_ID 
                        # value: KEYVALUE 
                        # AWS key secret for authenticating with the AWS API. 
                        # This is only here for examples. It's recommended you instead use 
                        # a project like kube2iam for granting access. 
                        #- name: AWS_SECRET_ACCESS_KEY 
                        # value: SECRETVALUE 
                    # Repository location of the ALB Ingress Controller. 
                        # image: docker.io/amazon/aws-alb-ingress-controller:v1.1.6
                        image: docker.io/amazon/aws-alb-ingress-controller:v1.2.0-alpha.1
                    serviceAccountName: alb-ingress-controller
                INGRESSCONTROLLER

}

resource "local_file" "ingress_controller" {
    content = "${local.INGRESS_CONTROLLER_DEPLOY}"
    filename = "${path.module}/alb-ingress-controller.yaml"
}

resource "null_resource" "deploy_ingress_controller" { 
    # ...

    provisioner "local-exec" {
        command = "kubectl apply -f alb-ingress-controller.yaml"
        working_dir = "${path.module}"
    }
    depends_on = ["local_file.kubeconfig","aws_eks_node_group.eks-worker-ng", "local_file.ingress_controller","null_resource.copy_kubeconfig_to_localpath"]
}