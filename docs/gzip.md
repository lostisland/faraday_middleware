# Gzip Compression

Use `FaradayMiddleware::Gzip` to automatically decompress response bodies. If the "Accept-Encoding" header wasn't set in the request, this sets it to "gzip,deflate" and appropriately handles the compressed response from the server. This resembles what Ruby does internally in Net::HTTP#get.

This middleware is NOT necessary when these adapters are used:

- `net_http`
- `net_http_persistent`
- `em_http`

