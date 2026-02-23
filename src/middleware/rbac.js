module.exports.requireRole = (role) => (req, res, next) => { if (req.user?.role === role) next(); else res.status(403).json({ error: 'Forbidden' }); };
