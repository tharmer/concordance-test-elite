# Operational Runbook

## Incident Response
1. Check /health and /ready endpoints
2. Review logs with correlation ID
3. Check Prometheus metrics for anomalies
4. Verify downstream service health
5. If circuit breaker is open, check downstream logs

## Scaling
- Gateway is stateless — scale horizontally
- Rate limit state is in Redis — ensure Redis cluster health

## Rollback
1. Identify last known good version
2. Run: gh workflow run deploy.yml -f version=v1.x.x
3. Verify health checks pass
4. Monitor error rates for 15 minutes
