module.exports.sanitizeInput = (str) => str.replace(/[<>"'&]/g, '');
