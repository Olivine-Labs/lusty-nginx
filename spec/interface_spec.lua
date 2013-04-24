package.path = './spec/?.lua;../src/?.lua;'..package.path
ngx = {
  var = {
    uri = ""
  }
}
describe("log interface", function()
  local lusty = require 'lusty'()

  it("has a request function", function()
    local server = require 'init'(lusty)
    assert.are.equal(type(server.request), "function")
  end)

  it("doesn't break when I try to run that function without nginx", function()
    local server = require 'init'(lusty)
    assert.has_no.errors(function() server.request() end)
  end)

end)
