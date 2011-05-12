### Using with connect

On the Server

    rpc = new require('minirpc').RPC

    # simple
    rpc.sum = (a, b) -> a + b

    # you can access current HTTP request ( available as rpc._request )
    rpc.get_header = (header_name) ->
      rpc._request.headers[header_name]

    # async? no problem, just return a function that takes a callback(res, err) as argument
    rpc.get_weather = ( zip_code ) -> 
      ( cb ) ->
        some_remote_service zip_code, true, (res) -> cb null, res

    # if you're using express/connect
    app.use rpc._middleware()

On The Client

    <!-- Will dynamically create proxies for every method attached to rpc -->
    <script src="/___rpc.js"></script>
    <script>
      ___rpc.sum 1, 2, (res) ->
        console.log "1 + 2 = #{res}"
    </script>

### Installation

    npm install minirpc

### Error handling



### Related

http://groups.google.com/group/json-rpc/web/json-rpc-2-0


### Changelog

0.0.2
* moved index.js to root to comply with [new NPM spec](http://groups.google.com/group/npm-/msg/10ab9647ad6eaff7) 
