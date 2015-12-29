# Changelog

### Next

* Use Hashie's Rash instead of [tcocca/rash](https://github.com/tcocca/rash) in `FaradayMiddleware::Rashify`.

  This comes with major behavior changes for `FaradayMiddleware::Rashify`.

  * Method access (eg. `.name` for ['name']) no longer provided.
  * Attribute camelCase translation (eg. `myName` becomes 'my_name') no longer performed.

### 0.0.2 September 25, 2010

* Mashify now handles arrays of non-hashes

### 0.0.1 June 27, 2010

* MultiJSON
* Mashify
