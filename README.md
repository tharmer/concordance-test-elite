# Platform Gateway Service

A high-performance API gateway handling authentication, routing, rate limiting, and observability for the platform microservices architecture.

## Overview

The Platform Gateway is the single entry point for all client requests. It handles:

- **Authentication & Authorization** — JWT validation, OAuth2 flows, API key management, RBAC
- **Request Routing** — Dynamic routing to downstream services with circuit breakers
- **Rate Limiting** — Per-user and per-endpoint rate limiting with sliding window
- **Observability** — Structured logging, distributed tracing, metrics collection
- **Security** — Input validation, CORS, CSP headers, request signing

## Architecture

The gateway follows a middleware pipeline pattern:

```
Client → TLS → Rate Limiter → Auth → Router → Circuit Breaker → Service
                                                                    ↓
Client ← Response Transform ← Cache ← Logging ← Response ←────────┘
```

Each middleware is independently testable and configurable. See `docs/architecture.md` for detailed design decisions and `docs/adr/` for architecture decision records.

## Getting Started

### Prerequisites

- Node.js 20+ (LTS)
- npm 10+
- Docker (for integration tests)

### Installation

```bash
npm ci
```

### Development

```bash
npm run dev          # Start with hot reload
npm run lint         # ESLint + Prettier check
npm test             # Unit tests with coverage
npm run test:e2e     # Playwright integration tests
```

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| PORT | No | 3000 | Server port |
| JWT_SECRET | Yes | — | JWT signing key |
| REDIS_URL | No | localhost:6379 | Cache/rate limit store |
| LOG_LEVEL | No | info | Logging verbosity |
| DOWNSTREAM_URL | Yes | — | Backend service URL |

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | /health | None | Health check |
| GET | /ready | None | Readiness probe |
| POST | /api/v1/auth/token | None | Get auth token |
| POST | /api/v1/auth/refresh | Bearer | Refresh token |
| ANY | /api/v1/* | Bearer | Proxied to downstream |

## Monitoring

- Prometheus metrics at `/metrics`
- Health check at `/health` (HTTP 200 = healthy)
- Readiness probe at `/ready` (checks downstream connectivity)
- Structured JSON logs with correlation IDs

## Runbooks

See `docs/runbook.md` for operational procedures:
- Incident response checklist
- Scaling procedures
- Rollback instructions
- Common failure modes

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for our development workflow, commit conventions, and review process.

## Security

See [SECURITY.md](SECURITY.md) for our responsible disclosure policy.

## License

MIT — see [LICENSE](LICENSE) for details.
