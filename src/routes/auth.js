const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();
const SECRET = process.env.JWT_SECRET || 'dev-only';

router.post('/token', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Credentials required' });
  const token = jwt.sign({ sub: email, role: 'user' }, SECRET, { expiresIn: '1h' });
  const refreshToken = jwt.sign({ sub: email, type: 'refresh' }, SECRET, { expiresIn: '7d' });
  res.json({ token, refreshToken, expiresIn: 3600 });
});

router.post('/refresh', (req, res) => {
  const { refreshToken } = req.body;
  try {
    const decoded = jwt.verify(refreshToken, SECRET);
    if (decoded.type !== 'refresh') return res.status(400).json({ error: 'Invalid refresh token' });
    const token = jwt.sign({ sub: decoded.sub, role: 'user' }, SECRET, { expiresIn: '1h' });
    res.json({ token, expiresIn: 3600 });
  } catch { res.status(401).json({ error: 'Invalid or expired refresh token' }); }
});

module.exports = router;
