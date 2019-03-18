local statsd_schema = require "kong.plugins.statsd-advanced.schema"
local validate_entity = require("spec.helpers").validate_plugin_config_schema

describe("Plugin: statsd-advanced (schema)", function()
  it("accepts empty config", function()
    local ok, err = validate_entity({}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("accepts empty metrics", function()
    local metrics_input = {}
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("accepts just one metrics", function()
    local metrics_input = {
      {
        name = "request_count",
        stat_type = "counter",
        sample_rate = 1
      }
    }
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("rejects if name or stat not defined", function()
    local metrics_input = {
      {
        name = "request_count",
        sample_rate = 1
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("field required for entity check", err.config.metrics.stat_type)
    local metrics_input = {
      {
        stat_type = "counter",
        sample_rate = 1
      }
    }
    _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("field required for entity check", err.config.metrics.name)
  end)
  it("rejects counters without sample rate", function()
    local metrics_input = {
      {
        name = "request_count",
        stat_type = "counter",
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("required field missing", err.config.metrics.sample_rate)
  end)
  it("rejects invalid metrics name", function()
    local metrics_input = {
      {
        name = "invalid_name",
        stat_type = "counter",
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.match("expected one of:.+", err.config.metrics.name)
  end)
  it("rejects invalid stat type", function()
    local metrics_input = {
      {
        name = "request_count",
        stat_type = "invalid_stat",
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("value must be counter", err.config.metrics.stat_type)
  end)
  it("rejects if customer identifier missing", function()
    local metrics_input = {
      {
        name = "status_count_per_user",
        stat_type = "counter",
        sample_rate = 1
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("required field missing", err.config.metrics.consumer_identifier)
  end)
  it("rejects invalid service identifier", function()
    local metrics_input = {
      {
        name = "status_count",
        stat_type = "counter",
        sample_rate = 1,
        service_identifier = "fooo",
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.match("expected one of:.+", err.config.metrics.service_identifier)
  end)
  it("accepts empty service identifier", function()
    local metrics_input = {
      {
        name = "status_count",
        stat_type = "counter",
        sample_rate = 1,
      }
    }
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("accepts valid service identifier", function()
    local metrics_input = {
      {
        name = "status_count",
        stat_type = "counter",
        sample_rate = 1,
        service_identifier = "service_id",
      }
    }
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("rejects invalid workspace identifier", function()
    local metrics_input = {
      {
        name = "status_count_per_workspace",
        stat_type = "counter",
        sample_rate = 1,
        workspace_identifier = "fooo",
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.match("expected one of:.+", err.config.metrics.workspace_identifier)
  end)
  it("rejects empty workspace identifier", function()
    local metrics_input = {
      {
        name = "status_count_per_workspace",
        stat_type = "counter",
        sample_rate = 1,
      }
    }
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("required field missing", err.config.metrics.workspace_identifier)
  end)
  it("accepts valid workspace identifier", function()
    local metrics_input = {
      {
        name = "status_count_per_workspace",
        stat_type = "counter",
        sample_rate = 1,
        workspace_identifier = "workspace_id",
      }
    }
    local ok, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("rejects if metric has wrong stat type", function()
    local metrics_input = {
      {
        name = "unique_users",
        stat_type = "counter"
      }
    }
    local _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("value must be set", err.config.metrics.stat_type)
    metrics_input = {
      {
        name = "status_count",
        stat_type = "set",
        sample_rate = 1
      }
    }
    _, err = validate_entity({ metrics = metrics_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("value must be counter", err.config.metrics.stat_type)
  end)
  it("accepts empty allow status codes configuration parameter", function()
    local allow_status_codes_input = {}

    local ok, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("accepts if allow status codes configuration parameter is given status codes in form of ranges", function()
    local allow_status_codes_input = {
      "200-299",
      "300-399"
    }

    local ok, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)
  it("rejects if allow status codes configuration is given as alphabet values", function()
    local allow_status_codes_input = {
      "test"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: test", err.config.allow_status_codes)
  end)
  it("rejects if allow status codes configuration is given as special characters", function()
    local allow_status_codes_input = {
      "$%%"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: $%%", err.config.allow_status_codes)
  end)
  it("rejects if allow status codes configuration is given as alphabet values with dash symbol which indicates range", function()
    local allow_status_codes_input = {
      "test-test",
      "test-test"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: test-test", err.config.allow_status_codes)
  end)
  it("rejects if allow status codes configuration is given as alphabet an numeric values with dash symbol which indicates range", function()
    local allow_status_codes_input = {
      "test-299",
      "300-test"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: test-299", err.config.allow_status_codes)
  end)
  it("rejects if one of allow status codes configuration is invalid", function()
    local allow_status_codes_input = {
      "200-300",
      "test-test"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: test-test", err.config.allow_status_codes)
  end)
  it("rejects if allow status codes configuration is given as numeric values without dash symbol which indicates range", function()
    local allow_status_codes_input = {
      "200",
      "299"
    }

    local _, err = validate_entity({ allow_status_codes = allow_status_codes_input}, statsd_schema)
    assert.not_nil(err)
    assert.equal("invalid value: 200", err.config.allow_status_codes)
  end)
  it("accepts valid udp_packet_size", function()
    local ok, err = validate_entity({ udp_packet_size = 0}, statsd_schema)
    assert.is_nil(err)
    assert.truthy(ok)
    local ok, err = validate_entity({ udp_packet_size = 1}, statsd_schema)
    assert.is_nil(err)
    assert.truthy(ok)
    local ok, err = validate_entity({ udp_packet_size = 10000}, statsd_schema)
    assert.is_nil(err)
    assert.truthy(ok)
  end)
  it("rejects invalid udp_packet_size", function()
    local ok, err = validate_entity({ udp_packet_size = -1}, statsd_schema)
    assert.not_nil(err)
    assert.equal("value should be between 0 and 65507", err.config.udp_packet_size)
    local ok, err = validate_entity({ udp_packet_size = "a"}, statsd_schema)
    assert.not_nil(err)
    assert.equal("expected a number", err.config.udp_packet_size)
    local ok, err = validate_entity({ udp_packet_size = 65508}, statsd_schema)
    assert.not_nil(err)
    assert.equal("value should be between 0 and 65507", err.config.udp_packet_size)
  end)
end)
