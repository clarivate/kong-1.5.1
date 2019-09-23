local cjson   = require "cjson"
local helpers = require "spec.helpers"


local fixtures = {
  http_mock = {
    collector = [[
      server {
          server_name collector;
          listen 5000;

          location /service-map {
              content_by_lua_block {
                local cjson = require("cjson")
                local query_args = ngx.req.get_uri_args()
                if query_args.response_code then
                  ngx.status = query_args.response_code
                end

                ngx.say(cjson.encode(query_args))
              }
          }

          location /alerts {
              content_by_lua_block {
                local cjson = require("cjson")
                local query_args = ngx.req.get_uri_args()
                if query_args.response_code then
                  ngx.status = query_args.response_code
                end

                ngx.say(cjson.encode(query_args))
              }
          }

          location /status {
              content_by_lua_block {
                local cjson = require("cjson")
                local query_args = ngx.req.get_uri_args()
                local status = {
                  immunity = {
                    available = true,
                    version = "1.7.1"
                  },
                  brain = {
                    available = true,
                    version = "1.7.1"
                  }
                }
                if query_args.response_code then
                  ngx.status = query_args.response_code
                end

                ngx.say(cjson.encode(status))
              }
          }
      }
    ]]
  },
}


for _, strategy in helpers.each_strategy() do
  describe("Plugin: collector (API) [#" .. strategy .. "]", function()
    local admin_client
    local bp
    local db
    local workspace1
    local workspace2

    lazy_setup(function()
      local plugin_config = {
        host = '127.0.0.1',
        port = 5000,
        https = false,
        log_bodies = true,
        queue_size = 1,
        flush_timeout = 1
      }
      bp, db = helpers.get_db_utils(strategy, nil, { "collector" })

      workspace1 = bp.workspaces:insert({ name = "workspace1"})
      workspace2 = bp.workspaces:insert({ name = "workspace2"})

      bp.plugins:insert_ws({ name = "collector", config = plugin_config }, workspace1)
      bp.plugins:insert_ws({ name = "collector", config = plugin_config }, workspace2)


      assert(helpers.start_kong({
        database = strategy,
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "collector" }, nil, nil, fixtures))
      admin_client = helpers.admin_client()
    end)

    before_each(function()
      db:truncate("service_maps")
    end)

    teardown(function()
      if admin_client then
        admin_client:close()
      end

      helpers.stop_kong()
    end)

    describe("/service_maps", function()
      describe("GET", function()
        it("forwards query parameters and adds workspace_name", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/service_maps?service_id=123"
          })
          local body = assert.res_status(200, res)
          local expected_params = {
            workspace_name = workspace2.name,
            service_id = "123",
          }
          assert.are.same(cjson.decode(body), expected_params)
        end)

        it("returns whatever response code returned by upstream", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/service_maps?response_code=300"
          })
          assert.res_status(300, res)
        end)
      end)
    end)

    describe("/collector/alerts", function()
      describe("GET", function()
        it("forwards query parameters and adds workspace_name", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/collector/alerts?severity=high&alert_name=traffic"
          })
          local body = assert.res_status(200, res)
          local expected_params = {
            workspace_name = workspace2.name,
            alert_name = "traffic",
            severity = "high"
          }
          assert.are.same(cjson.decode(body), expected_params)
        end)

        it("returns whatever response code returned by upstream", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/collector/alerts?severity=high&response_code=300"
          })
          assert.res_status(300, res)
        end)
      end)
    end)

    describe("/collector/status", function()
      describe("GET", function()
        it("returns backend status", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/collector/status"
          })
          local body = assert.res_status(200, res)

          local expected_status = {
            immunity = {
              available = true,
              version = "1.7.1"
            },
            brain = {
              available = true,
              version = "1.7.1"
            }
          }
          assert.are.same(cjson.decode(body), expected_status)
        end)

        it("returns whatever response code is returned by upstream", function()
          local res = assert(admin_client:send {
            method  = "GET",
            path    = "/workspace2/collector/status?response_code=400"
          })
          assert.res_status(400, res)
        end)
      end)
    end)
  end)
end
