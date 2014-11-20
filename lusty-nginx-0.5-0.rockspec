package = "lusty-nginx"
version = "0.5-0"
source = {
  url = "https://github.com/Olivine-Labs/lusty-nginx/archive/v0.5.tar.gz",
  dir = "lusty-nginx-0.5"
}
description = {
  summary = "Nginx plugin for lusty.",
  detailed = [[
    Allows for interaction with the ngx_lua module (and openresty).
  ]],
  homepage = "http://olivinelabs.com/lusty-nginx/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
   modules = {
    ["lusty-nginx.init"] = "lusty-nginx/init.lua",
    ["lusty-nginx.request"] = "lusty-nginx/request.lua",
    ["lusty-nginx.response"] = "lusty-nginx/response.lua",
    ["lusty-nginx.log"] = "lusty-nginx/log.lua"
  }
}
