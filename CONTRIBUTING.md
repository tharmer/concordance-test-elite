# Contributing to Platform Gateway

## Development Workflow

1. Create a branch from `main` with a descriptive name
2. Make changes following our conventions below
3. Open a PR — minimum 2 approving reviews required
4. All CI checks must pass before merge
5. Squash merge to keep history clean

## Commit Convention

We strictly follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): add new feature
fix(scope): fix specific bug
docs: update documentation
test: add or modify tests
chore: maintenance tasks
perf: performance improvements
refactor: code restructuring
ci: CI/CD changes
```

All commits must reference an issue: `feat(auth): add OAuth2 flow (#34)`

## Code Review Standards

- Every PR requires substantive review (no rubber stamps)
- Reviewers should check: correctness, security, performance, test coverage
- Use "Request Changes" for blocking issues, "Comment" for suggestions
- PR author addresses all feedback before merging

## Testing Requirements

- Unit tests for all business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Coverage must not decrease
