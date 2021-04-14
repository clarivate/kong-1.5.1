-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local helpers = require "spec.helpers"

describe("origins config option", function()
  local proxy_client
  local bp

  lazy_setup(function()
    bp = helpers.get_db_utils(nil, {
      "routes",
      "services",
    })
  end)

  lazy_teardown(function()
    if proxy_client then
      proxy_client:close()
    end

    helpers.stop_kong()
  end)

  it("respects origins for overriding resolution", function()
    local service = bp.services:insert({
      protocol = helpers.mock_upstream_protocol,
      host     = helpers.mock_upstream_host,
      port     = 1, -- wrong port
    })
    bp.routes:insert({
      service = service,
      hosts = { "mock_upstream" }
    })

    -- Check that error occurs trying to talk to port 1
    assert(helpers.start_kong({
      nginx_conf = "spec/fixtures/custom_nginx.template",
    }))

    proxy_client = helpers.proxy_client()
    local res = proxy_client:get("/request", {
      headers = { Host = "mock_upstream" }
    })
    assert.res_status(502, res)
    proxy_client:close()

    -- Now restart with origins option
    assert(helpers.restart_kong({
      nginx_conf = "spec/fixtures/custom_nginx.template",
      origins = string.format("%s://%s:%d=%s://%s:%d",
        helpers.mock_upstream_protocol,
        helpers.mock_upstream_host,
        1,
        helpers.mock_upstream_protocol,
        helpers.mock_upstream_host,
        helpers.mock_upstream_port),
    }))

    proxy_client = helpers.proxy_client()
    local res = proxy_client:get("/request", {
      headers = { Host = "mock_upstream" }
    })
    assert.res_status(200, res)
  end)
end)
