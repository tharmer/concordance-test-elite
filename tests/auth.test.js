const jwt = require('jsonwebtoken');
const { authMiddleware } = require('../src/middleware/auth');

describe('Auth Middleware', () => {
  const mockRes = () => ({ status: jest.fn().mockReturnThis(), json: jest.fn() });

  test('rejects without token', () => {
    const res = mockRes();
    authMiddleware({ headers: {} }, res, jest.fn());
    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('accepts valid token', () => {
    const token = jwt.sign({ sub: 'test@test.com' }, 'dev-only');
    const next = jest.fn();
    authMiddleware({ headers: { authorization: `Bearer ${token}` } }, mockRes(), next);
    expect(next).toHaveBeenCalled();
  });

  test('rejects expired token', () => {
    const token = jwt.sign({ sub: 'test@test.com' }, 'dev-only', { expiresIn: '-1h' });
    const res = mockRes();
    authMiddleware({ headers: { authorization: `Bearer ${token}` } }, res, jest.fn());
    expect(res.status).toHaveBeenCalledWith(401);
  });
});
