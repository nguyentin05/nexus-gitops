# Branch Strategy — gitops-repo

## Strategy
Environment Branching

## Branches

| Branch | Environment | Updated by |
|---|---|---|
| `main` | dev | CI bot (automated) |
| `production` | prod | Manual PR from `main` |

No feature branches. All commits are automated by CI pipelines from `app-repo` and `aiops-repo`.

## Flow

```
CI pipeline → auto-commit image tag → main → ArgoCD syncs dev

main → PR (manual review) → production → ArgoCD syncs prod
```

## Branch Protection

**`main`**
- Only CI bot token can push directly
- No force push, no deletion

**`production`**
- PR from `main` required
- Minimum 1 approval required
- No force push, no deletion