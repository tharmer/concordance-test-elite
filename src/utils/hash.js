const crypto = require('crypto');
module.exports.hashApiKey = (key) => crypto.createHash('sha256').update(key).digest('hex');
