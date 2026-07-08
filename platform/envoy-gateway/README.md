# Envoy Gateway

Envoy Gateway replaces the old API Gateway-as-application direction.

Current skeleton:

- installs Envoy Gateway controller with Helm
- creates `GatewayClass/envoy`
- creates `apps/public-gateway`
- routes `/auth` to `auth-service`

The production edge is still a later infra task: `CloudFront -> WAF -> ALB -> Envoy Gateway`.
