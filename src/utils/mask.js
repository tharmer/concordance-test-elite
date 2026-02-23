module.exports.mask = (str, visibleChars = 4) => str.slice(0, visibleChars) + '*'.repeat(Math.max(0, str.length - visibleChars));
