return function(lusty)

  --table created to replace nested if in __index. Contains lookup of values to return for request
  local requestIndex = {
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
    end,

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
    end,

    url = function(request)
      return ngx.var.uri
    end
  }

  --table created to replace nested if in __index. Contains lookup of values to return for response
  local responseIndex = {
    status = function(response)
      return ngx.status
    end,

    headers = function(response)
      return ngx.header
    end
  }

  --same as above but for newIndex
  local responseNewIndex = {
    status = function(response, value)
      ngx.status = value
    end
  }

  local function getRequest()
    return setmetatable({},{
      -- lazy-load all of the ngx data requests so we only call out to ngx when we
      -- have to
      __index = function(self, key)
        local value = requestIndex[key]
        return value and value(self) or rawget(self, key)
      end
    })
  end

  local function getResponse()
    return setmetatable({
      ["end"] = function() end,

      send = function(body)
        ngx.say(body)
        ngx.flush(true)
      end
    },{
      __index = function(self, key)
        local value = responseIndex[key]
        return value and value(self) or rawget(self, key)
      end,

      __newindex = function(self, key, value)
        local value = responseNewIndex[key]
        return value and value(self, value) or rawset(self, key, value)
      end
    })
  end

  return setmetatable({
    request = function(self, request, response)
      return lusty:request(request or getRequest(), response or getResponse())
    end
  },
  {
    __index = function(self, key)
      return rawget(self, key) or lusty[key]
    end
  })
end
