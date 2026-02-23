const express = require('express');
const router = express.Router();

router.all('/*', (req, res) => {
  res.json({ message: 'Proxied', path: req.path, method: req.method });
});

module.exports = router;
const { createBreaker } = require('../middleware/circuitBreaker');
