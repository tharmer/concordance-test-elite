module.exports.ipWhitelist = (allowed) => (req, res, next) => { if (allowed.includes(req.ip)) next(); else res.status(403).end(); };
