module.exports.corsOptions = { origin: process.env.ALLOWED_ORIGINS?.split(',') || '*', credentials: true };
