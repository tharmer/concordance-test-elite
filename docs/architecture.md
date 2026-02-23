# Architecture

## Overview

The Platform Gateway implements a middleware pipeline pattern where each concern
(auth, rate limiting, routing, caching) is an independent, composable middleware.

## Key Design Decisions

- **Middleware pipeline** over monolithic handler (see ADR-001)
- **TypeScript** for type safety at scale (see ADR-001)
- **Redis** for distributed state (rate limits, cache, sessions)
- **Circuit breaker pattern** for downstream resilience

## Component Diagram

```
┌─────────────────────────────────────────────┐
│                  Gateway                      │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────────┐ │
│  │ Auth │→│ Rate │→│Route │→│ Circuit    │ │
│  │      │ │Limit │ │      │ │ Breaker    │ │
│  └──────┘ └──────┘ └──────┘ └────────────┘ │
└─────────────────────────────────────────────┘
```
