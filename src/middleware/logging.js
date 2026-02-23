function requestLogger(req, res, next) {
  const start = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({ level: 'info', method: req.method, path: req.path, status: res.statusCode, duration: Date.now() - start, correlationId: req.id }));
  });
  next();
}
module.exports = { requestLogger };
