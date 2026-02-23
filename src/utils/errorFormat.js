module.exports.formatError = (err) => ({ message: err.message, code: err.code || 'UNKNOWN', ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }) });
