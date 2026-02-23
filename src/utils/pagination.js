module.exports.paginate = (items, page = 1, size = 20) => ({ data: items.slice((page-1)*size, page*size), total: items.length, page, size });
