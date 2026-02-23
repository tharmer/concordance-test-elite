const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const { authMiddleware } = require('./middleware/auth');
const { rateLimiter } = require('./middleware/rateLimit');
const { requestLogger } = require('./middleware/logging');
const { requestId } = require('./middleware/requestId');
const { metricsMiddleware, metricsEndpoint } = require('./middleware/metrics');
const authRoutes = require('./routes/auth');
const proxyRoutes = require('./routes/proxy');
const healthRoutes = require('./routes/health');

const app = express();
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json({ limit: '5mb' }));
app.use(requestId);
app.use(requestLogger);
app.use(metricsMiddleware);

app.use('/', healthRoutes);
app.get('/metrics', metricsEndpoint);
app.use('/api/v1/auth', rateLimiter, authRoutes);
app.use('/api/v1', rateLimiter, authMiddleware, proxyRoutes);

app.use((err, req, res, next) => {
  const status = err.status || 500;
  console.error(JSON.stringify({ level: 'error', correlationId: req.id, error: err.message }));
  res.status(status).json({ error: err.message, correlationId: req.id });
});

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => console.log(`Gateway listening on port ${PORT}`));

process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10000);
});

module.exports = app;
