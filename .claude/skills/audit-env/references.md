# Environment Variable & Secrets Protection — Reference

Distilled from K-Hole depth research (2026-03-14, 3 digs, 124+ sources surveyed).

## Layered Defense Model (Industry Consensus)

```
Layer 1: Pre-commit     → gitleaks, ggshield (local, fast, blocking)
Layer 2: CI/CD          → TruffleHog, GitGuardian Actions (server-side, thorough)
Layer 3: Runtime        → Vault, Doppler, AWS Secrets Manager (injection, rotation)
Layer 4: Monitoring     → GitGuardian dashboard, Stripe key exposure alerts
Layer 5: Incident       → Automated rotation playbooks, key deactivation
```

## Tools & Integration Patterns

### Secrets Scanning (Pre-commit + CI/CD)

| Tool | Repo | Integration | Strength |
|------|------|-------------|----------|
| gitleaks | github.com/gitleaks/gitleaks | Pre-commit hook, GitHub Action (`gitleaks-action`) | Fast local detection, TOML config, custom regex |
| TruffleHog | github.com/trufflesecurity/trufflehog | GitHub Action (`trufflehog-action`), CLI | Credential verification (actually tests if key works), deep git history scan |
| GitGuardian ggshield | github.com/GitGuardian/ggshield | Pre-commit hook, GitHub Action (`ggshield-action`), CLI | 350+ detector patterns, dashboard for triage, policy engine |

### Runtime Secrets Management

| Tool | Model | Best For |
|------|-------|----------|
| Doppler | Centralized SaaS, syncs to Vercel/AWS/Railway | Small-medium teams, developer velocity |
| HashiCorp Vault | Self-hosted or HCP, dynamic secrets, PKI | Enterprise, complex rotation, multi-cloud |
| AWS Secrets Manager | AWS-native, automatic rotation, IAM integration | AWS-heavy stacks |
| Infisical | Open-source, self-hostable, SDK-based | Teams wanting Doppler-like DX without SaaS lock-in |

### Privacy-as-Code

| Tool | Repo | Purpose |
|------|------|---------|
| Fides | github.com/ethyca/fides | Annotate systems with privacy metadata, automated risk assessment |
| Privado | github.com/Privado-Inc/privado | Data flow scanner — maps PII across codebases |
| Google Cloud DLP | cloud.google.com/dlp | PII detection API — 150+ infoTypes, de-identification |

## Platform-Specific Patterns

### Next.js / Vercel
- `NEXT_PUBLIC_*` variables are embedded in client JS at build time — treat as PUBLIC
- Server-only secrets: use `process.env.SECRET` only in Server Components, Route Handlers, or `getServerSideProps`
- Vercel Environment Variables: set per-environment (Production, Preview, Development) — never share across

### Stripe
- Proactive key exposure alerts — Stripe monitors GitHub for leaked API keys
- Environment-specific secret paths in AWS Secrets Manager
- IAM role-based isolation per environment

### Roblox
- Secrets only available in production and Team Create — NOT in local playtesting
- Constrains attack surface to trusted environments

### Cloudflare
- Workers secrets: `wrangler secret put` — stored encrypted, injected at runtime
- Never in `wrangler.toml` (that's committed to git)

## Incident Response Playbook (Leaked Secret)

1. **Detect**: Scanning tool alerts (GitGuardian, TruffleHog) or manual discovery
2. **Assess**: What type of secret? What scope of access? When was it committed?
3. **Rotate**: Generate new secret immediately — do NOT revoke old one yet
4. **Deploy**: Push new secret to all consumers (production, staging, CI/CD)
5. **Revoke**: Disable the old secret only AFTER all consumers have the new one
6. **Audit**: Check access logs for the old secret's exposure window
7. **Remediate**: Remove from git history if committed (`git filter-branch` or BFG Repo-Cleaner)
8. **Document**: Postmortem — how did it leak? What gate failed?

## What This Means for the Hardening Construct

The `/audit-env` skill should check for:
1. Pre-commit hooks installed (gitleaks or equivalent)
2. CI/CD scanning configured (GitHub Actions workflow with secret scanning)
3. No `.env` files in git history (not just gitignore — check `git log`)
4. `NEXT_PUBLIC_*` audit (only URLs and public IDs, never secrets)
5. Runtime injection pattern (not hardcoded in code)
6. Rotation readiness (can secrets be rotated without downtime?)
