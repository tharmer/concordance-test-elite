const redis = require('ioredis');
class Cache {
  constructor() { this.store = new Map(); }
  get(key) { return this.store.get(key); }
  set(key, val, ttl = 300) { this.store.set(key, val); setTimeout(() => this.store.delete(key), ttl * 1000); }
}
module.exports = new Cache();
