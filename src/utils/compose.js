module.exports.compose = (...fns) => (x) => fns.reduceRight((acc, fn) => fn(acc), x);
