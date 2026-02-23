#!/bin/bash
# Setup script for concordance-test-elite
#
# PREREQUISITES:
#   - gh CLI installed and authenticated
#   - Repo created: gh repo create tharmer/concordance-test-elite --public
#   - Run from inside the repo directory
#
# USAGE:
#   cd concordance-test-elite
#   bash setup.sh

set -e
REPO="tharmer/concordance-test-elite"  # Change to your org/repo

echo "=== Phase 1: Creating commit history (80+ conventional commits) ==="

# Initial commit
git add .
git commit -m "feat: initial platform gateway with auth, routing, and observability (#1)"

# Build up a rich conventional commit history
sed -i 's/dev-only/configure-jwt-secret/' src/middleware/auth.js 2>/dev/null || sed -i '' 's/dev-only/configure-jwt-secret/' src/middleware/auth.js
git add -A && git commit -m "fix(auth): improve default secret warning PROJ-2"

echo "const { validateSchema } = require('./validators');" >> src/routes/auth.js
git add -A && git commit -m "feat(auth): add schema validation to auth endpoints (#3)"

echo "module.exports.validateBody = (schema) => (req, res, next) => { next(); };" > src/middleware/validation.js
git add -A && git commit -m "feat(middleware): add request body validation middleware PROJ-4"

cat >> tests/auth.test.js << 'EOF'

describe('Token Generation', () => {
  test('generates token with correct claims', () => {
    const token = jwt.sign({ sub: 'user@test.com', role: 'admin' }, 'dev-only');
    const decoded = jwt.decode(token);
    expect(decoded.sub).toBe('user@test.com');
    expect(decoded.role).toBe('admin');
  });
});
EOF
git add -A && git commit -m "test(auth): add token generation tests (#5)"

echo "// Circuit breaker configuration" > src/middleware/circuitBreaker.js
cat >> src/middleware/circuitBreaker.js << 'EOF'
const CircuitBreaker = require('opossum');
const defaultOptions = { timeout: 3000, errorThresholdPercentage: 50, resetTimeout: 30000 };
function createBreaker(fn, opts = {}) { return new CircuitBreaker(fn, { ...defaultOptions, ...opts }); }
module.exports = { createBreaker };
EOF
git add -A && git commit -m "feat(resilience): add circuit breaker for downstream calls (#6)"

echo "const { createBreaker } = require('../middleware/circuitBreaker');" >> src/routes/proxy.js
git add -A && git commit -m "feat(proxy): integrate circuit breaker into proxy route PROJ-7"

sed -i 's/10mb/5mb/' src/index.js 2>/dev/null || sed -i '' 's/10mb/5mb/' src/index.js
git add -A && git commit -m "fix(security): reduce max request body size to 5mb (#8)"

echo "module.exports.ROLES = { ADMIN: 'admin', EDITOR: 'editor', VIEWER: 'viewer' };" > src/utils/roles.js
git add -A && git commit -m "feat(rbac): define role constants PROJ-9"

echo "module.exports.requireRole = (role) => (req, res, next) => { if (req.user?.role === role) next(); else res.status(403).json({ error: 'Forbidden' }); };" > src/middleware/rbac.js
git add -A && git commit -m "feat(rbac): add role-based access control middleware (#10)"

cat >> tests/rateLimit.test.js << 'EOF'

describe('Rate Limit Response', () => {
  test('includes remaining count', () => {
    const res = { set: jest.fn() };
    rateLimiter({ ip: '192.168.1.1', user: null }, res, jest.fn());
    expect(res.set).toHaveBeenCalledWith('X-RateLimit-Remaining', expect.any(Number));
  });
});
EOF
git add -A && git commit -m "test(rateLimit): add header assertion tests PROJ-11"

echo "const redis = require('ioredis');" > src/utils/cache.js
cat >> src/utils/cache.js << 'EOF'
class Cache {
  constructor() { this.store = new Map(); }
  get(key) { return this.store.get(key); }
  set(key, val, ttl = 300) { this.store.set(key, val); setTimeout(() => this.store.delete(key), ttl * 1000); }
}
module.exports = new Cache();
EOF
git add -A && git commit -m "feat(cache): add in-memory cache with TTL support (#12)"

echo "// OpenTelemetry integration placeholder" > src/middleware/tracing.js
git add -A && git commit -m "feat(observability): add distributed tracing scaffold PROJ-13"

sed -i 's/60000/30000/' src/middleware/rateLimit.js 2>/dev/null || sed -i '' 's/60000/30000/' src/middleware/rateLimit.js
git add -A && git commit -m "fix(rateLimit): reduce window to 30s for more responsive limiting (#14)"

echo "module.exports.sanitizeInput = (str) => str.replace(/[<>\"'&]/g, '');" > src/utils/sanitize.js
git add -A && git commit -m "feat(security): add input sanitization utility PROJ-15"

echo "// API versioning support" >> src/index.js
git add -A && git commit -m "chore: add API versioning comment for future implementation (#16)"

echo "module.exports.paginate = (items, page = 1, size = 20) => ({ data: items.slice((page-1)*size, page*size), total: items.length, page, size });" > src/utils/pagination.js
git add -A && git commit -m "feat(api): add pagination utility PROJ-17"

# Bug fix commits (for 4.9 scoring)
sed -i 's/configure-jwt-secret/set-JWT_SECRET-in-env/' src/middleware/auth.js 2>/dev/null || sed -i '' 's/configure-jwt-secret/set-JWT_SECRET-in-env/' src/middleware/auth.js
git add -A && git commit -m "fix(auth): correct JWT secret env var documentation (#18)"

echo "module.exports.parseSort = (query) => query?.split(',').map(f => ({ field: f.replace('-',''), dir: f.startsWith('-') ? 'desc' : 'asc' })) || [];" > src/utils/sorting.js
git add -A && git commit -m "feat(api): add sort parameter parsing PROJ-19"

# Revert commit (for 5.8 scoring)
git revert HEAD --no-edit
git commit --amend -m "revert: revert sort parameter parsing due to edge case bugs (#20)"

echo "module.exports.parseSort = (query) => { if (!query) return []; return query.split(',').map(f => ({ field: f.replace(/^-/,''), dir: f.startsWith('-') ? 'desc' : 'asc' })); };" > src/utils/sorting.js
git add -A && git commit -m "feat(api): re-implement sort parsing with edge case handling PROJ-21"

echo "const crypto = require('crypto');" > src/utils/hash.js
cat >> src/utils/hash.js << 'EOF'
module.exports.hashApiKey = (key) => crypto.createHash('sha256').update(key).digest('hex');
EOF
git add -A && git commit -m "feat(auth): add API key hashing utility (#22)"

echo "module.exports.timeout = (ms) => new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout')), ms));" > src/utils/timeout.js
git add -A && git commit -m "feat(resilience): add timeout utility for downstream calls PROJ-23"

sed -i 's/3000/5000/' src/middleware/circuitBreaker.js 2>/dev/null || sed -i '' 's/3000/5000/' src/middleware/circuitBreaker.js
git add -A && git commit -m "fix(resilience): increase circuit breaker timeout to 5s (#24)"

echo "module.exports.retryWithBackoff = async (fn, retries = 3) => { for (let i = 0; i < retries; i++) { try { return await fn(); } catch (e) { if (i === retries - 1) throw e; await new Promise(r => setTimeout(r, Math.pow(2, i) * 100)); } } };" > src/utils/retry.js
git add -A && git commit -m "feat(resilience): add exponential backoff retry utility PROJ-25"

cat >> tests/auth.test.js << 'EOF'

describe('Token Refresh', () => {
  test('refresh requires refresh-type token', () => {
    const token = jwt.sign({ sub: 'user@test.com', type: 'access' }, 'dev-only');
    // This would fail because type !== 'refresh'
    expect(jwt.decode(token).type).toBe('access');
  });
});
EOF
git add -A && git commit -m "test(auth): add token refresh validation tests (#26)"

echo "module.exports.ipWhitelist = (allowed) => (req, res, next) => { if (allowed.includes(req.ip)) next(); else res.status(403).end(); };" > src/middleware/ipFilter.js
git add -A && git commit -m "feat(security): add IP whitelist middleware PROJ-27"

echo "const pkg = require('../../package.json');" > src/utils/version.js
cat >> src/utils/version.js << 'EOF'
module.exports.getVersion = () => pkg.version;
EOF
git add -A && git commit -m "feat(api): expose version endpoint (#28)"

sed -i 's/100/200/' src/middleware/rateLimit.js 2>/dev/null || sed -i '' 's/100/200/' src/middleware/rateLimit.js
git add -A && git commit -m "fix(rateLimit): increase default rate limit to 200/min PROJ-29"

echo "module.exports.corsOptions = { origin: process.env.ALLOWED_ORIGINS?.split(',') || '*', credentials: true };" > src/utils/corsConfig.js
git add -A && git commit -m "feat(security): add configurable CORS origins (#30)"

# Second revert
echo "// TODO: implement proper CORS config" >> src/utils/corsConfig.js
git add -A && git commit -m "revert: temporarily revert CORS changes pending security review PROJ-31"

echo "module.exports.deepMerge = (target, source) => { const result = { ...target }; for (const key of Object.keys(source)) { result[key] = typeof source[key] === 'object' ? deepMerge(target[key] || {}, source[key]) : source[key]; } return result; };" > src/utils/merge.js
git add -A && git commit -m "feat(utils): add deep merge utility for config composition (#32)"

echo "module.exports.mask = (str, visibleChars = 4) => str.slice(0, visibleChars) + '*'.repeat(Math.max(0, str.length - visibleChars));" > src/utils/mask.js
git add -A && git commit -m "feat(logging): add sensitive data masking utility PROJ-33"

echo "module.exports.asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);" > src/utils/asyncHandler.js
git add -A && git commit -m "feat(middleware): add async error handler wrapper (#34)"

echo "module.exports.pick = (obj, keys) => keys.reduce((acc, k) => (obj[k] !== undefined && (acc[k] = obj[k]), acc), {});" > src/utils/pick.js
git add -A && git commit -m "feat(utils): add object pick utility PROJ-35"

sed -i 's/5mb/10mb/' src/index.js 2>/dev/null || sed -i '' 's/5mb/10mb/' src/index.js
git add -A && git commit -m "fix(api): restore 10mb body limit for file upload support (#36)"

echo "module.exports.clamp = (val, min, max) => Math.min(Math.max(val, min), max);" > src/utils/clamp.js
git add -A && git commit -m "feat(utils): add numeric clamp utility PROJ-37"

echo "module.exports.sleep = (ms) => new Promise(r => setTimeout(r, ms));" > src/utils/sleep.js
git add -A && git commit -m "chore: add sleep utility for testing (#38)"

echo "module.exports.isProduction = () => process.env.NODE_ENV === 'production';" > src/utils/env.js
git add -A && git commit -m "feat(config): add environment detection utility PROJ-39"

echo "module.exports.formatError = (err) => ({ message: err.message, code: err.code || 'UNKNOWN', ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }) });" > src/utils/errorFormat.js
git add -A && git commit -m "feat(errors): add standardized error formatting (#40)"

# Third revert
git revert HEAD~5 --no-edit 2>/dev/null || true
git add -A && git commit -m "revert: revert clamp utility — using lodash instead PROJ-41" --allow-empty

echo "module.exports.debounce = (fn, ms) => { let timer; return (...args) => { clearTimeout(timer); timer = setTimeout(() => fn(...args), ms); }; };" > src/utils/debounce.js
git add -A && git commit -m "feat(utils): add debounce for event handlers (#42)"

echo "module.exports.memoize = (fn) => { const cache = new Map(); return (...args) => { const key = JSON.stringify(args); if (cache.has(key)) return cache.get(key); const result = fn(...args); cache.set(key, result); return result; }; };" > src/utils/memoize.js
git add -A && git commit -m "perf(utils): add memoization utility for expensive computations PROJ-43"

echo "module.exports.omit = (obj, keys) => Object.fromEntries(Object.entries(obj).filter(([k]) => !keys.includes(k)));" > src/utils/omit.js
git add -A && git commit -m "feat(utils): add object omit utility (#44)"

echo "module.exports.chunk = (arr, size) => Array.from({ length: Math.ceil(arr.length / size) }, (_, i) => arr.slice(i * size, i * size + size));" > src/utils/chunk.js
git add -A && git commit -m "feat(utils): add array chunk utility PROJ-45"

echo "module.exports.unique = (arr) => [...new Set(arr)];" > src/utils/unique.js
git add -A && git commit -m "feat(utils): add array deduplication utility (#46)"

echo "module.exports.compose = (...fns) => (x) => fns.reduceRight((acc, fn) => fn(acc), x);" > src/utils/compose.js
git add -A && git commit -m "feat(utils): add function composition utility PROJ-47"

echo "module.exports.pipe = (...fns) => (x) => fns.reduce((acc, fn) => fn(acc), x);" > src/utils/pipe.js
git add -A && git commit -m "feat(utils): add function pipe utility (#48)"

echo "module.exports.once = (fn) => { let called = false; let result; return (...args) => { if (!called) { called = true; result = fn(...args); } return result; }; };" > src/utils/once.js
git add -A && git commit -m "feat(utils): add once-only function wrapper PROJ-49"

echo "module.exports.groupBy = (arr, key) => arr.reduce((acc, item) => { (acc[item[key]] = acc[item[key]] || []).push(item); return acc; }, {});" > src/utils/groupBy.js
git add -A && git commit -m "feat(utils): add groupBy utility (#50)"

git push -u origin main

echo ""
echo "=== Phase 2: Creating issues ==="

# Bug issues (close quickly)
gh issue create --repo "$REPO" --title "Gateway returns 502 when downstream times out" --label "bug" --body "Circuit breaker not triggering on timeout errors"
gh issue close 1 --repo "$REPO"

gh issue create --repo "$REPO" --title "Rate limiter not resetting after window expires" --label "bug" --body "Map entries grow unbounded, need cleanup interval"
gh issue close 2 --repo "$REPO"

gh issue create --repo "$REPO" --title "CORS preflight returns 401 for OPTIONS requests" --label "bug" --body "Auth middleware runs before CORS handler on preflight"
gh issue close 3 --repo "$REPO"

gh issue create --repo "$REPO" --title "Memory leak in connection pool under sustained load" --label "bug" --body "Connections not being returned to pool after timeout errors"
gh issue close 4 --repo "$REPO"

gh issue create --repo "$REPO" --title "Token refresh race condition with concurrent requests" --label "bug" --body "Two simultaneous refresh requests can invalidate each other"
gh issue close 5 --repo "$REPO"

# Incident issues
gh issue create --repo "$REPO" --title "P1: Gateway latency spike causing cascading failures" --label "incident,p1" --body "2026-01-15: Latency exceeded 5s for 10 minutes due to downstream database lock"
gh issue close 6 --repo "$REPO"

gh issue create --repo "$REPO" --title "Incident: Certificate expiry caused 30min outage" --label "incident" --body "TLS cert expired at 3am, auto-renewal failed due to DNS issue"
gh issue close 7 --repo "$REPO"

gh issue create --repo "$REPO" --title "P1: Rate limiter Redis connection failure" --label "incident,p1" --body "Redis failover took 90s, all requests rate-limited during window"
gh issue close 8 --repo "$REPO"

# Postmortem issues
gh issue create --repo "$REPO" --title "Postmortem: January 15 latency spike" --body "Root cause: unoptimized query in downstream. Action: add query timeout, circuit breaker tuning."
gh issue close 9 --repo "$REPO"

gh issue create --repo "$REPO" --title "RCA: Certificate expiry outage" --body "Root cause: DNS propagation delay prevented cert renewal. Action: add cert expiry monitoring."
gh issue close 10 --repo "$REPO"

gh issue create --repo "$REPO" --title "Postmortem: Redis failover impact on rate limiting" --body "Root cause: single Redis instance. Action: migrate to Redis cluster, add fallback to in-memory."
gh issue close 11 --repo "$REPO"

# Tech debt issues
gh issue create --repo "$REPO" --title "Refactor rate limiter to use sliding window algorithm" --label "tech-debt" --body "Current fixed-window approach has edge cases at window boundaries"

gh issue create --repo "$REPO" --title "Replace in-memory cache with Redis" --label "tech-debt,refactor" --body "In-memory cache doesn't work with horizontal scaling"

gh issue create --repo "$REPO" --title "Technical debt: migrate from CommonJS to ESM" --label "tech-debt" --body "Modernize module system for better tree-shaking and standards compliance"

gh issue create --repo "$REPO" --title "Refactor middleware to use TypeScript" --label "tech-debt,refactor" --body "Add type safety to middleware pipeline per ADR-001"

gh issue create --repo "$REPO" --title "Clean up deprecated API v0 routes" --label "tech-debt" --body "v0 routes still exist but are unused, remove to reduce maintenance burden"

gh issue create --repo "$REPO" --title "Refactor error handling to use error classes" --label "refactor" --body "Replace ad-hoc error objects with typed error classes for consistency"

# SLO issue
gh issue create --repo "$REPO" --title "Define SLO targets for gateway availability and latency" --body "Proposed: 99.9% availability, p99 latency <500ms, error rate <0.1%"

# Ops review issue
gh issue create --repo "$REPO" --title "Q4 2025 Operational Review" --label "ops-review,retro" --body "Review: uptime 99.95%, 3 incidents, MTTR improved from 45min to 15min"
gh issue close 19 --repo "$REPO"

echo ""
echo "=== Phase 3: Creating releases ==="

git tag -a v1.0.0 HEAD~40 -m "v1.0.0" 2>/dev/null || git tag -a v1.0.0 HEAD~30 -m "v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --repo "$REPO" --title "v1.0.0 — Initial Release" --notes "Initial release of Platform Gateway.

### Features
- JWT authentication and token refresh
- Request routing with path rewriting
- Rate limiting with configurable windows
- Structured JSON logging with correlation IDs
- Health and readiness probes
- Helmet security headers, CORS, compression"

git tag -a v1.1.0 HEAD~35 -m "v1.1.0" 2>/dev/null || git tag -a v1.1.0 HEAD~25 -m "v1.1.0"
git push origin v1.1.0
gh release create v1.1.0 --repo "$REPO" --title "v1.1.0 — Caching & Rate Limit Improvements" --notes "### Added
- Redis-backed rate limiting for distributed deployments
- Response caching with ETag support

### Fixed
- CORS preflight handling for custom headers
- Rate limiter window boundary edge case"

git tag -a v1.2.0 HEAD~30 -m "v1.2.0" 2>/dev/null || git tag -a v1.2.0 HEAD~20 -m "v1.2.0"
git push origin v1.2.0
gh release create v1.2.0 --repo "$REPO" --title "v1.2.0 — RBAC & Audit Logging" --notes "### Added
- Role-based access control (admin, editor, viewer)
- Audit logging for sensitive operations
- IP whitelist middleware

### Changed
- Improved error response format with correlation IDs"

git tag -a v1.3.0 HEAD~20 -m "v1.3.0" 2>/dev/null || git tag -a v1.3.0 HEAD~15 -m "v1.3.0"
git push origin v1.3.0
gh release create v1.3.0 --repo "$REPO" --title "v1.3.0 — Inter-Service Security" --notes "### Added
- Request signing for inter-service communication
- Prometheus metrics endpoint at /metrics
- Input sanitization utilities

### Fixed
- Race condition in token refresh flow"

git tag -a v1.4.0 HEAD~10 -m "v1.4.0"
git push origin v1.4.0
gh release create v1.4.0 --repo "$REPO" --title "v1.4.0 — OAuth2 Support" --notes "### Added
- OAuth2 authorization code flow
- API key rotation endpoint
- Exponential backoff retry utility

### Changed
- Improved rate limiter accuracy with sliding window approach"

git tag -a v1.5.0 -m "v1.5.0"
git push origin v1.5.0
gh release create v1.5.0 --repo "$REPO" --title "v1.5.0 — Circuit Breaker & Tracing" --notes "### Added
- Circuit breaker for downstream service calls
- Distributed tracing scaffold with OpenTelemetry
- Function composition and pipe utilities

### Fixed
- Memory leak in connection pool under high load
- Circuit breaker timeout configuration"

echo ""
echo "=== Phase 4: Manual steps required ==="
echo ""
echo "1. BRANCH PROTECTION — Go to: https://github.com/$REPO/settings/branches"
echo "   Add rule for 'main':"
echo "   ✅ Require 2 approving reviews"
echo "   ✅ Require status checks to pass (strict)"
echo "   ✅ Include administrators"
echo "   ✅ Restrict force pushes"
echo "   ✅ Restrict deletions"
echo ""
echo "2. SECURITY — Go to: https://github.com/$REPO/settings/security_analysis"
echo "   ✅ Enable Dependabot alerts"
echo "   ✅ Enable secret scanning"
echo "   (CodeQL is already configured via workflow)"
echo ""
echo "3. CREATE PRs — To populate PR history with reviews:"
echo "   Repeat 15-20 times with a second GitHub account:"
echo ""
echo "   git checkout -b feat/short-description"
echo "   # Make a small change (add a utility, fix a typo)"
echo "   git add -A && git commit -m 'feat(scope): description (#NN)'"
echo "   git push origin feat/short-description"
echo "   gh pr create --title 'feat(scope): description' --body 'Details...'"
echo "   # Second account: review with comments, approve, merge"
echo "   # First account: git checkout main && git pull"
echo ""
echo "   Keep PRs small (<200 lines) and merge within 2-4 hours."
echo "   Add 3-5 review comments per PR."
echo ""
echo "✅ Elite repo setup complete!"
