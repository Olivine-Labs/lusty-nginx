local server = { }

local index = {
  headers = function(request)
    return ngx.req.get_headers()
  end,

  body = function(request)
    if not request.body_was_read then
      request.body_was_read = true
      ngx.req.read_body()
      request.body = ngx.req.get_body_data()
    end
    return request.body
  end

  file = function(request)
    if not request.body_was_read then
      request.body_was_read = true
      ngx.req.read_body()
      local file = ngx.req.get_body_file()
      request.file = file
    end
    return request.file
  end,

  query = function(request)
    return ngx.req.get_uri_args()
  end,

  method = function(request)
    return ngx.req.get_method()
  end,

  params = function(request)
    if not request.post_was_read then
      request.post_was_read = true
      request.params = ngx.req.get_post_args()
    end
    return request.params
  end
}

local function getRequest()
  local request = setmetatable({
    url = ngx.var.uri
  },{
    -- lazy-load all of the ngx data requests so we only call out to ngx when we
    -- have to
    __index = function(self, key)
      return index[key] and index[key](self) or rawget(self, key)
    end
  })

  return request
end

local function getResponse()
  local response = setmetatable({
    status = 404,
    headers = {},

    ["end"] = function() end,

    send = function(body)
      ngx.say(body)
      ngx.flush(true)
    end
  },{
    __index = function(self, key)
      if key == "status" then
        return ngx.status
      else
        return rawget(self, key)
      end
    end,

    __newindex = function(self, key, value)
      if key == "status" then
        ngx.status = value
      elseif key == "body" then
        rawset(self, key, value)
      end
    end
  })

  response.headers = ngx.header

  return response
end

server.getRequest = getRequest
server.getResponse = getResponse

return server
