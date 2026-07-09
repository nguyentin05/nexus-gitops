# AWS Load Balancer Controller

AWS Load Balancer Controller reconciles Kubernetes `Ingress` resources into AWS ALBs.

Current dev setup:

- Helm chart: `aws-load-balancer-controller` from `https://aws.github.io/eks-charts`
- Namespace: `kube-system`
- ServiceAccount: `aws-load-balancer-controller`
- IRSA role: `dev-aws-load-balancer-controller-irsa`
- Public ALB is defined in `platform/envoy-gateway/manifests/alb-ingress.yaml` and forwards to the Envoy Gateway data-plane service.

Terraform owns the IAM role and policy. GitOps owns the controller deployment and ALB-facing Kubernetes resources.
