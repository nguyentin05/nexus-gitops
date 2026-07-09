# Envoy Gateway

Envoy Gateway replaces the old API Gateway-as-application direction.

Current skeleton:

- installs Envoy Gateway controller with Helm
- creates `GatewayClass/envoy`
- creates `apps/public-gateway`
- routes `/auth` to `auth-service`
- exposes Envoy through an AWS ALB managed by AWS Load Balancer Controller

The remaining production edge work is `Route53 -> CloudFront -> WAF -> ALB`.
