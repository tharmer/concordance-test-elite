const crypto = require('crypto');
function requestId(req, res, next) {
  req.id = req.headers['x-correlation-id'] || crypto.randomUUID();
  res.set('X-Correlation-ID', req.id);
  next();
}
module.exports = { requestId };
