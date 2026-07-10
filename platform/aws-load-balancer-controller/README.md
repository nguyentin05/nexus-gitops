# AWS Load Balancer Controller

AWS Load Balancer Controller is installed so Kubernetes can bind workloads to AWS load balancer target groups.

Current dev setup:

- Helm chart: `aws-load-balancer-controller` from `https://aws.github.io/eks-charts`
- Namespace: `kube-system`
- ServiceAccount: `aws-load-balancer-controller`
- IRSA role: `dev-aws-load-balancer-controller-irsa`
- Terraform owns the public ALB, listener, target group, WAF, CloudFront, and DNS.
- GitOps owns `TargetGroupBinding`, which registers the Envoy Gateway data-plane service into Terraform's `dev-envoy-gateway` target group.

The controller should not create the public API ALB from an `Ingress` in this architecture.
