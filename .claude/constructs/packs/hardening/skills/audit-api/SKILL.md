---
name: audit-api
description: "API endpoint security surface scan — auth gates, data exposure, rate limiting, input validation."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Agent
triggers:
  - "audit api"
  - "security scan api"
  - "check api endpoints"
capabilities:
  model_tier: opus
  danger_level: safe
  effort_hint: medium
---

# API Security Surface Audit

Scan every API route for auth gaps, data exposure, rate limiting, and input validation.

## Workflow

### Phase 1: Route Discovery

Find all route files. For each framework:
- **Hono**: Glob `**/routes/*.ts`, search for `.get(`, `.post(`, `.put(`, `.patch(`, `.delete(`
- **Express**: Same patterns + `router.`
- **Next.js API**: Glob `**/app/api/**/route.ts`

Build a route table: `[method, path, auth_middleware, rate_limit, input_validation]`

### Phase 2: Auth Gate Audit

For each route, check:

1. **Missing auth on write endpoints**: Any POST/PUT/PATCH/DELETE without `requireAuth()` or equivalent
2. **Missing auth on sensitive reads**: GET endpoints returning user-specific data (emails, wallets, tokens, keys)
3. **Role confusion**: Endpoints using tier/plan checks instead of role checks for admin operations
4. **Optional auth leaks**: Endpoints with `optionalAuth()` that behave differently when authed — does the unauthed path expose anything it shouldn't?

Severity: CRITICAL if write endpoint has no auth, HIGH if role check is wrong

### Phase 3: Data Exposure Audit

For each endpoint response, check:

1. **PII in public responses**: User IDs, emails, wallet addresses, names returned by unauthenticated endpoints
2. **Internal IDs exposed**: Database UUIDs, foreign keys that enable enumeration
3. **Verbose errors**: Stack traces, SQL errors, internal paths in error responses
4. **Metadata leakage**: Server version, framework info, process details in headers or health endpoints

Severity: MEDIUM for user IDs, HIGH for emails/wallets, CRITICAL for tokens/keys

### Phase 4: Rate Limiting Audit

For each write endpoint:

1. **Missing rate limiter**: No rate limit middleware applied
2. **Fail-open behavior**: Does the rate limiter fail open when Redis/backing store is unavailable?
3. **Insufficient limits**: Authentication endpoints with >10/min, general writes with >100/min
4. **Bandwidth amplification**: Download/export endpoints with no per-endpoint limit

### Phase 5: Input Validation Audit

For each endpoint accepting user input:

1. **Unvalidated path params**: Path segments passed directly to DB queries or file system
2. **Missing body validation**: POST/PUT without schema validation (Zod, Joi, etc.)
3. **URL parameters as redirects**: `success_url`, `callback_url`, `redirect` without origin validation — open redirect vectors

### Output

```markdown
## API Security Surface Audit

### Route Table
| Method | Path | Auth | Rate Limit | Validation | Findings |
|--------|------|------|-----------|-----------|----------|

### Findings
| ID | Severity | File:Line | Issue | Fix |
|----|----------|-----------|-------|-----|

### Summary
- N routes scanned
- N auth gaps
- N data exposure issues
- N rate limit gaps
- N validation gaps
```

## What This Skill Does NOT Do

- Does not test live endpoints (no curl, no HTTP requests)
- Does not review business logic correctness
- Does not audit frontend code (see audit-auth for auth flows)
- Does not review database schema (see audit-data-privacy for data exposure)
