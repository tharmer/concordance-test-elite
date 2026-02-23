module.exports.parseSort = (query) => query?.split(',').map(f => ({ field: f.replace('-',''), dir: f.startsWith('-') ? 'desc' : 'asc' })) || [];
