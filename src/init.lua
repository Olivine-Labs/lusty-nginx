local request = require 'request'
local response = require 'response'

--returns a request table for this server
--uses metatables to memoize calls out to nginx
local function getRequest()

  local memo = {}
  return setmetatable({},{
    -- lazy-load all of the ngx data requests so we only call out to ngx when we
    -- have to
    __index = function(self, key)
      local func = request.index[key]
      return func and func(memo) or memo[key]
    end,

    __newindex = function(self, key, value)
      memo[key] = value
    end
  })
end

--returns a response table for this server
--uses metatables to memoize calls out to nginx
local function getResponse()

  local memo = {}
  return setmetatable({},{
    __index = function(self, key)
      local func = response.index[key]
      return func and func(memo) or memo[key]
    end,

    __newindex = function(self, key, value)
      local func = response.newindex[key]
      return func and func(memo, value) or rawset(memo, key, value)
    end
  })
end

return function(lusty)

  local server = {
    request = function(self, request, response)
      return lusty:request(request or getRequest(), response or getResponse())
    end
  }

  return setmetatable({},
  {
    __index = function(self, key)
      return server[key] or lusty[key]
    end,

    __newindex = function(self, key, value)
      lusty[key] = value
    end
  })
end
