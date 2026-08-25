# Nexus GitOps

## Overview

This repository is the source of truth for the desired Kubernetes state of the
Nexus platform. ArgoCD continuously reconciles platform components,
security controls, observability services, routing resources, and application
workloads from Git into separate development and production clusters.

The repository owns:

- ArgoCD App-of-Apps definitions and sync ordering
- Helm charts for microservices architecture from nexus-app
- environment-specific application and platform configuration
- Vault, ESO, Envoy Gateway, Kyverno, Falco, and the observability stack
- development DAST and reviewed production promotion workflows
- production canary delivery with Argo Rollouts and Prometheus analysis

## Environment Organization

Environment configuration follows this hierarchy:

```text
envs/<environment>/<cloud>/<region>/
|-- applications/    # ArgoCD Application definitions
`-- platform/        # Environment-specific Helm values and manifests
```

The current environments are:

```text
envs/
|-- dev/aws/ap-southeast-1/
`-- prod/aws/ap-southeast-1/
```

| Environment | Branch | ArgoCD application root | Application workload |
| --- | --- | --- | --- |
| Development | `main` | `envs/dev/aws/ap-southeast-1/applications` | Kubernetes Deployment |
| Production | `production` | `envs/prod/aws/ap-southeast-1/applications` | Argo Rollouts canary |

Reusable platform defaults and manifests live in `platform/`. Reusable
application charts live in `charts/`. Each environment selects those shared
resources and applies only its required overrides.

This layout can add another environment, cloud platform, or region without
mixing its ArgoCD applications and values with an existing deployment target.

## Delivery Flow

1. A service change is merged into app services.
2. Application CI validates the service, builds and scans the image, publishes it to ECR, and signs it with Cosign.
3. The application workflow opens a PR that updates the service image tag in values-dev.yaml on main.
4. GitOps CI runs change detection, environment-specific Helm lint, Kubeconform, and Trivy configuration scanning.
5. The development PR auto-merges after its required checks pass.
6. Development ArgoCD reconciles the new immutable image as a Kubernetes Deployment.
7. DAST waits for that exact image and a healthy rollout, then scans the service OpenAPI endpoint with OWASP ZAP.
8. A successful DAST run creates or updates a service-specific promotion PR targeting production and requests manual review.
9. After approval and merge, production ArgoCD reconciles the image and Argo Rollouts performs the Prometheus-gated canary deployment.
10. Kyverno validates the workload at admission while Falco and the observability stack monitor it at runtime.

Service-specific promotion branches and concurrency groups prevent unrelated
services from conflicting. A newer validated image updates the existing open
promotion PR for the same service.

## Sync Wave Ordering

ArgoCD sync waves establish dependencies between platform components:

| Wave | Components | Purpose |
| --- | --- | --- |
| `-1` | Namespaces | Create resource boundaries before namespaced workloads |
| `1` | Vault | Start the secret source of truth |
| `2` | External Secrets Operator | Install the secret synchronization controller |
| `3` | SecretStore, ExternalSecret, and Vault configuration | Connect workloads to Vault-backed secrets |
| `4` | Kyverno | Install the admission and policy controllers |
| `5` | Kyverno policies | Activate workload security rules after Kyverno is ready |
| `6` | Monitoring and AWS Load Balancer Controller | Provide metrics and AWS target registration |
| `7` | Envoy Gateway, Loki, OpenTelemetry, Falco, and production Argo Rollouts | Install traffic, telemetry, runtime security, and rollout controllers |
| `8` | Envoy routing configuration and OpenTelemetry logs | Configure public routing and OTLP log collection |
| `9` | Application services and Grafana dashboards | Deploy business workloads after their dependencies |

## Prerequisites

- Nexus AWS infrastructure provisioned from `nexus-infra`
- a reachable EKS cluster and valid AWS credentials
- AWS CLI, kubectl, Helm, Terraform
- a GitHub App with repository `Contents: Read-only` permission for ArgoCD
- IAM roles and EKS access required by ArgoCD bootstrap and GitHub Actions OIDC
- AWS KMS, RDS, ECR, SQS, and target group outputs for the selected environment
- repository secrets required by Vault synchronization and production promotion

## Getting Started

Coming soon.
