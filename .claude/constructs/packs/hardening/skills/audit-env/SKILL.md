---
name: audit-env
description: "Scan for secret leakage in env files, client code, git history, and build artifacts."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
triggers:
  - "audit env"
  - "scan for secrets"
  - "check env variables"
capabilities:
  model_tier: sonnet
  danger_level: safe
  effort_hint: small
---

# Environment Variable & Secrets Audit

Find leaked secrets before they become incidents.

## Workflow

### Phase 1: Committed Secrets

Check if `.env` files are tracked in git:

```bash
git ls-tree -r HEAD --name-only | grep -E '\.env'
git log --all --oneline -- '.env*' '**/.env*'
```

If any `.env` files were ever committed, they're in git history forever. Flag for secret rotation.

### Phase 2: Gitignore Coverage

Check `.gitignore` for:
- `.env` — root env
- `.env.*` — variant env files
- `*.pem` — private keys
- `*.key` — key files
- `.run/` — runtime state

Verify patterns actually match existing files:
```bash
git status --ignored --short | grep '.env'
```

### Phase 3: Client-Side Exposure

Search for `NEXT_PUBLIC_*` or `VITE_*` env vars in the codebase:

1. List all `NEXT_PUBLIC_*` references → these are bundled into client JS
2. For each: is it a URL (safe), or a secret (critical)?
3. Check for `process.env.SECRET` in client components (Next.js will embed these at build time if referenced)

Patterns that SHOULD be NEXT_PUBLIC:
- API base URLs
- Dynamic Labs environment IDs
- Convex deployment URLs
- Analytics IDs

Patterns that should NEVER be NEXT_PUBLIC:
- API keys, tokens, secrets
- Database URLs
- Private keys
- Webhook secrets

### Phase 4: Hardcoded Secrets in Code

Search for patterns:
```
sk_[a-zA-Z0-9]{20,}
pk_[a-zA-Z0-9]{20,}
ghp_[a-zA-Z0-9]{36}
AKIA[0-9A-Z]{16}
-----BEGIN.*PRIVATE KEY-----
password\s*[:=]\s*["'][^"']+["']
secret\s*[:=]\s*["'][^"']+["']
```

Exclude: test fixtures, example configs, documentation

### Phase 5: Build Artifact Leakage

Check if `.next/`, `dist/`, `build/` directories:
1. Are gitignored
2. Contain embedded env vars in the built JS bundles
3. Contain source maps that expose server-side code

### Output

```markdown
## Environment & Secrets Audit

### Committed Secrets
| File | Status | Action Needed |
|------|--------|---------------|

### Client-Side Exposure
| Variable | Value Type | Safe? |
|----------|-----------|-------|

### Hardcoded Secrets
| File:Line | Pattern | Severity |
|-----------|---------|----------|

### Summary
- N env files checked
- N committed to git history
- N client-exposed variables
- N hardcoded secrets found
```
