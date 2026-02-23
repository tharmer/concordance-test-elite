const limits = new Map();
function rateLimiter(req, res, next) {
  const key = req.user?.sub || req.ip;
  const now = Date.now();
  const windowMs = 60000;
  const max = 100;
  if (!limits.has(key)) limits.set(key, []);
  const hits = limits.get(key).filter(t => t > now - windowMs);
  hits.push(now);
  limits.set(key, hits);
  res.set('X-RateLimit-Limit', max);
  res.set('X-RateLimit-Remaining', Math.max(0, max - hits.length));
  if (hits.length > max) return res.status(429).json({ error: 'Rate limit exceeded' });
  next();
}
module.exports = { rateLimiter };
