module.exports.groupBy = (arr, key) => arr.reduce((acc, item) => { (acc[item[key]] = acc[item[key]] || []).push(item); return acc; }, {});
