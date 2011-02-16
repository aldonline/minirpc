### Using with connect

On the Server

    rpc = new require('minirpc').RPC

    # simple
    rpc.sum = (a, b) -> a + b

    # you can access current HTTP request ( available as rpc._request )
    rpc.logout = ->
      # to kill a session for example
      delete rpc._request.session
      true

    # async? no problem, just return a function that takes a callback(res, err) as argument
    rpc.get_weather = ( zip_code ) -> 
      ( cb ) ->
        some_remote_service zip_code, true, (res) -> cb res

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

I have not released this as an NPM module yet because it is under heavy development. So the only way to use this is by getting source and linking via NPM link.
The following will do the trick.
    mkdir -p /usr/src
    cd /usr/src
    git clone git://github.com/aldonline/minirpc.git
    cd minirpc
    npm link .

### Error handling



### Related

http://groups.google.com/group/json-rpc/web/json-rpc-2-0

