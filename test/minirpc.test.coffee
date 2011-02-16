# http://groups.google.com/group/json-rpc/web/json-rpc-2-0

require 'coffee-script'
express = require 'express'
minirpc = require '../lib/minirpc'
assert = require 'assert'

x = exports

# create express server
server = express.createServer()
server.get '/', (req, res) -> res.send 'Hello World'

# create a mini RPC object
rpc = new minirpc.RPC

# setup mini RPC by adding a middleware layer on express
# there are other options
server.use rpc._middleware()

# attach some methods ( will be published )
rpc.sum = (a, b) ->
  a + b
rpc.get_header = (header_name) ->
  rpc._request.headers[header_name]

# due diligence. is the server + test stack working?
x.test_server_1 = ->
  assert.response server,
    url: '/'
    method: 'GET'
    ,
    (res) -> assert.equal res.body, 'Hello World'

x.test_rpc_javascript_stub_delivery = ->
  assert.response server,
    url: '/___minirpc.js'
    method: 'GET'
    ,
    (res) -> 
      assert.equal res.statusCode, 200
      assert.equal res.headers['content-type'], 'application/javascript'

x.test_execute = ->
  minirpc.execute rpc, ( method:'sum', params:[1, 2] ), (res, err) ->
    assert.equal res, 3

x.test_simple_rpc_call = ->
  assert.response server,
      url: '/___minirpc'
      method: 'POST'
      data: '{"jsonrpc": "2.0", "method": "sum", "params": [1, 2], "id": 1}'
      headers : {'Content-Type' : 'application/json; charset=utf8'}
      ,
      (res) ->
        assert.equal res.statusCode, 200
        assert.equal res.headers['content-type'], 'application/json'
        obj = JSON.parse res.body
        assert.equal obj.result, 3
        assert.equal obj.error, null
        assert.equal obj.id, 1

x.test_rpc_call_accessing_request = ->
  assert.response server,
      url: '/___minirpc'
      method: 'POST'
      data: '{"jsonrpc": "2.0", "method": "get_header", "params": ["foo"], "id": 1}'
      headers : {'Content-Type' : 'application/json; charset=utf8', 'foo':'bar'}
      ,
      (res) ->
        assert.equal res.statusCode, 200
        assert.equal res.headers['content-type'], 'application/json'
        obj = JSON.parse res.body
        assert.equal obj.result, 'bar'
        assert.equal obj.error, null
        assert.equal obj.id, 1
