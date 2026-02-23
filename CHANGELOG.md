# Changelog

## [1.5.0] - 2026-02-15
### Added
- Circuit breaker for downstream service calls
- Distributed tracing with OpenTelemetry
### Fixed
- Memory leak in connection pool under high load

## [1.4.0] - 2026-01-15
### Added
- OAuth2 authorization code flow
- API key rotation endpoint
### Changed
- Improved rate limiter accuracy with sliding window

## [1.3.0] - 2025-12-15
### Added
- Request signing for inter-service communication
- Prometheus metrics endpoint
### Fixed
- Race condition in token refresh

## [1.2.0] - 2025-11-15
### Added
- Role-based access control (RBAC)
- Audit logging for sensitive operations

## [1.1.0] - 2025-10-15
### Added
- Redis-backed rate limiting
- Response caching with ETags
### Fixed
- CORS preflight handling for custom headers

## [1.0.0] - 2025-09-15
### Added
- Initial release
- JWT authentication
- Request routing with path rewriting
- Structured logging
