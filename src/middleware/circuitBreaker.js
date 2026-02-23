// Circuit breaker configuration
const CircuitBreaker = require('opossum');
const defaultOptions = { timeout: 5000, errorThresholdPercentage: 50, resetTimeout: 30000 };
function createBreaker(fn, opts = {}) { return new CircuitBreaker(fn, { ...defaultOptions, ...opts }); }
module.exports = { createBreaker };
