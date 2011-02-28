# minifyjs = require 'minifyjs'

execute = ( methods, rpc, cb ) ->
  method = methods[rpc.method]
  if method?
    res = method.apply methods, rpc.params
    if typeof res is 'function'
      res cb
    else
      cb res
  else
    cb null, 'method not found'

debug = (msg_func) ->
  console.log msg_func()

send_json_response = (http_response, json_object) ->
  #http_response.headers['Content-Type'] = 'application/json'
  #http_response.send JSON.stringify json_object
  body = JSON.stringify json_object
  http_response.writeHead 200
    'Content-Type': 'application/json'
    'Content-Length': Buffer.byteLength body
  http_response.end body

get_req_payload = (req, cb) ->
  if req.rawBody?
    cb req.rawBody
  req.setEncoding 'utf8'
  data = ''
  req.on 'data', (chunk) -> data += chunk
  req.on 'end', -> cb data

get_req_json_payload = (req, cb) ->
  get_req_payload req, (data) ->
    cb JSON.parse data

# this function is executed on the client to create proxies
# see get_client_js() to understand how it gets serialized
create_client_proxy = ( path, names ) ->
  proxy = {}
  proxy._exec = (name, params, cb) ->
    data = JSON.stringify method:name, params:params
    # console.log ['exec', name, params, data ]
    jQuery.ajax
      type: 'POST'
      url: path
      data: data
      dataType: 'json'
      success:  ( res ) -> cb? res.result, res.error
      error: ( err ) -> cb? null, err
  create_method_proxy = (name) ->
    ->
      args = []
      func = null
      for a in arguments
        if typeof a is 'function' then func = a else args.push a
      proxy._exec name, args, func
  for name in names
    proxy[name] = create_method_proxy name
  proxy

get_client_js = ( path, names ) ->
  "var ___minirpc = (#{String create_client_proxy})('#{path}', #{JSON.stringify names});"

get_minified_client_js = (path, names, cb) ->
  cjs = get_client_js(path, names)
  cb cjs
  # TODO: pick a minifying engine with good nodejs/npm integration
  # minifyjs.minify cjs, (engine: 'yui'), (err, code) -> cb code

class RPC
  _endpoint_path: '/___minirpc'
  _script_path: '/___minirpc.js'
  _get_method_names: -> k for k of @ when 0 isnt k.indexOf '_'
  _get_client_js_stub: ->
    code = ''
  _middleware: => ( req, res, next ) =>
    # send javascript stub
    if req.url is @_script_path and req.method is 'GET'
      res.headers['Content-Type'] = 'application/javascript'
      get_minified_client_js @_endpoint_path, @_get_method_names(), (code) ->
        res.send code
    else if req.url is @_endpoint_path and req.method is 'POST'
      @_request = req # so method can access current request
      get_req_json_payload req, (data, err) =>
        execute @, data, ( xres, xerr ) =>
          xerr ?= null
          delete @_request
          send_json_response res, result:xres, error:xerr, id:data.id
    else
      next()
  _request: null

get_req_content = (req, cb) ->
  req.on 'data'

exports.RPC = RPC
exports.execute = execute
exports.get_client_js = get_client_js