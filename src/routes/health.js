const express = require('express');
const router = express.Router();

router.get('/health', (req, res) => res.json({ status: 'healthy', uptime: process.uptime() }));
router.get('/ready', (req, res) => res.status(200).json({ ready: true }));

module.exports = router;
