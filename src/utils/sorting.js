module.exports.parseSort = (query) => { if (!query) return []; return query.split(',').map(f => ({ field: f.replace(/^-/,''), dir: f.startsWith('-') ? 'desc' : 'asc' })); };
