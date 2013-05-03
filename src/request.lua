return {
  index = {
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
  },
  newindex = {
    method = function(request, value)
      ngx.req.set_method(ngx['HTTP_'..value])
    end
  }
}
