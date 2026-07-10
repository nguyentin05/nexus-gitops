# Envoy Gateway

Envoy Gateway replaces the old API Gateway-as-application direction.

Current skeleton:

- installs Envoy Gateway controller with Helm
- creates `GatewayClass/envoy`
- creates `apps/public-gateway`
- routes `/auth` to `auth-service`
- exposes Envoy through a Terraform-managed public ALB using `TargetGroupBinding`

Public request flow:

`Cloudflare DNS -> CloudFront -> Terraform ALB -> Terraform Target Group -> TargetGroupBinding -> Envoy Gateway -> HTTPRoute -> auth-service`
