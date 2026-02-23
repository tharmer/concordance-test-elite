const { rateLimiter } = require('../src/middleware/rateLimit');

describe('Rate Limiter', () => {
  test('allows requests under limit', () => {
    const req = { ip: '127.0.0.1', user: null };
    const res = { set: jest.fn() };
    const next = jest.fn();
    rateLimiter(req, res, next);
    expect(next).toHaveBeenCalled();
  });

  test('sets rate limit headers', () => {
    const res = { set: jest.fn() };
    rateLimiter({ ip: '10.0.0.1', user: null }, res, jest.fn());
    expect(res.set).toHaveBeenCalledWith('X-RateLimit-Limit', 100);
  });
});
