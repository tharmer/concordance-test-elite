const requests = { total: 0, byStatus: {}, byPath: {} };
function metricsMiddleware(req, res, next) {
  requests.total++;
  res.on('finish', () => {
    requests.byStatus[res.statusCode] = (requests.byStatus[res.statusCode] || 0) + 1;
  });
  next();
}
function metricsEndpoint(req, res) {
  res.set('Content-Type', 'text/plain');
  const lines = [`gateway_requests_total ${requests.total}`, ...Object.entries(requests.byStatus).map(([s, c]) => `gateway_requests_by_status{status="${s}"} ${c}`)];
  res.send(lines.join('\n'));
}
module.exports = { metricsMiddleware, metricsEndpoint };
