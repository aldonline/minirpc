express = require 'express'
minirpc = require '../../lib/minirpc'
connect = require 'connect'
assert = require 'assert'

server = express.createServer()

rpc = new minirpc.RPC

rpc.sum = (a, b) -> a + b
rpc.print_request_headers = ->
  JSON.stringify rpc._request.headers

# this is one way of setting up minirpc
server.use rpc._middleware()

server.use express.staticProvider __dirname

server.get '/', (req, res) -> 
  res.send 'Hello World'

server.listen 8080