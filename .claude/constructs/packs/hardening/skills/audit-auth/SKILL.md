---
name: audit-auth
description: "Audit authentication flow completeness — login, refresh, logout, session, RBAC, middleware."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Agent
triggers:
  - "audit auth"
  - "check auth flow"
  - "review authentication"
capabilities:
  model_tier: opus
  danger_level: safe
  effort_hint: medium
---

# Authentication Flow Audit

Verify the auth system works end-to-end — every edge case, every flow.

## Workflow

### Phase 1: Auth Flow Inventory

Map every auth-related endpoint and middleware:

1. **Login paths**: OAuth callbacks, wallet connect, API key auth, JWT exchange
2. **Token management**: Issue, refresh, revoke, blacklist
3. **Middleware**: What validates tokens? Where? Edge runtime vs server?
4. **Session storage**: Cookies (httpOnly?), localStorage, in-memory

Build a flow diagram:
```
Login → Token Issued → Token Stored → Token Validated → Token Refreshed → Logout → Token Revoked
```

### Phase 2: Login Flow Audit

For each login method:

1. **OAuth (GitHub/Google)**: Are tokens in redirect query strings? (They should be in fragments or server-side sessions)
2. **Wallet connect**: Is the signature verified server-side? Can a replayed signature authenticate?
3. **API keys**: Are they hashed/encrypted at rest? Is lookup constant-time (bcrypt)?
4. **JWT exchange**: Is the external JWT (Dynamic Labs, etc.) verified via JWKS with clock tolerance?

### Phase 3: Token Lifecycle Audit

1. **Access token**: How long does it live? Where is it stored? Is it httpOnly?
2. **Refresh token**: How long? Is it single-use (rotation)? Can it be revoked?
3. **Logout**: Does logout actually blacklist the refresh token? Or just clear the cookie?
4. **Expiry handling**: When access expires, does the refresh flow work? What if both expire?

The critical test: **After a user clicks "logout", can a captured refresh token still be used to get a new access token?** If yes, logout is broken.

### Phase 4: Middleware Audit

For each middleware that gates access:

1. **What does it validate?** Cookie existence? JWT structure? JWT signature? JWT expiry?
2. **What happens on failure?** Redirect? 401? Silent pass-through?
3. **Edge vs server**: Edge Runtime middleware can't do crypto operations (no Node.js crypto). Is JWT validation appropriate for this runtime?
4. **Bypass paths**: Can any route be accessed without hitting the middleware? (Check matcher config)

### Phase 5: RBAC Audit

1. **Role definitions**: Where are roles defined? admin, super_admin, user, enterprise?
2. **Role checks**: For each admin endpoint, what exactly is checked? `user.role`? `user.tier`? `user.isAdmin`?
3. **Privilege escalation**: Can a user change their own role? Can they access admin endpoints through a different path?
4. **Org membership**: How is org membership checked? How often? Can it be spoofed?

### Phase 6: Session Security

1. **Cookie attributes**: Secure? SameSite? Domain? Path? Max-Age?
2. **CSRF protection**: Is there CSRF validation on state-changing BFF routes?
3. **Token in URL**: Are tokens ever placed in URLs (query strings, fragments)?
4. **Token in logs**: Are tokens logged by any middleware or error handler?

### Output

```markdown
## Authentication Flow Audit

### Flow Map
[diagram of auth flows]

### Findings
| ID | Phase | Severity | Issue | File:Line | Fix |
|----|-------|----------|-------|-----------|-----|

### Token Lifecycle
| Token | Storage | Lifetime | Rotation | Revocation |
|-------|---------|----------|----------|------------|

### Middleware Chain
| Path | Middleware | Validates | Failure Mode |
|------|-----------|-----------|-------------|

### The Logout Test
- [ ] Capture refresh token before logout
- [ ] Click logout
- [ ] Try to use captured refresh token
- [ ] Expected: 401 (token blacklisted)
- [ ] Actual: [result]
```

## Patterns From Real Audits

These patterns were found in production codebases (constructs.network, 2026-03-14):

1. **Middleware checks cookie existence, not JWT validity**: Any non-empty cookie passes the gate. Fix: validate JWT structure + expiry at minimum.
2. **Logout doesn't send refresh token to API**: BFF clears the cookie client-side but never tells the server to blacklist the token. Fix: include refresh_token in logout POST body.
3. **OAuth tokens in redirect query string**: Tokens land in server logs, browser history, Referrer headers. Fix: use server-side session or one-time authorization code.
4. **Role check uses `tier` instead of `role`**: Enterprise-tier users get admin access. Fix: always check `user.role`, never `user.tier`, for authorization decisions.
