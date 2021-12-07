-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]


return {
  [2003003003] = {
    -- OSS plugins
    file_log = {
      "custom_fields_by_lua",
    },
    http_log = {
      "custom_fields_by_lua",
    },
    loggly = {
      "custom_fields_by_lua",
    },
    syslog = {
      "custom_fields_by_lua",
    },
    tcp_log = {
      "custom_fields_by_lua",
    },
    udp_log = {
      "custom_fields_by_lua",
    },
  },

  -- Any dataplane older than 2.4.0
  [2003999999] = {
    -- OSS plugins
    prometheus = {
      "per_consumer",
    },
    zipkin = {
      "tags_header",
    },
  },

  [2004001002] = {
    -- OSS plugins
    syslog = {
      "facility",
    },

    -- Enterprise plugins
    redis = {
      "connect_timeout",
      "keepalive_backlog",
      "keepalive_pool_size",
      "read_timeout",
      "send_timeout",
    },
  },

  -- Any dataplane older than 2.6.0
  [2005999999] = {
    -- OSS plugins
    acme = {
      "preferred_chain",
      -- Note: storage_config.vault fields are located in control_plane.lua
      --       This needs to be refactored and include nested field_sources
      --       Field elements may become their own file or a proper
      --       implementation per plugin with table functions
    },
    aws_lambda = {
      "base64_encode_body",
    },
    grpc_web = {
      "allow_origin_header",
    },
    request_termination = {
      "echo",
      "trigger",
    },

    -- Enterprise plugins
    canary = {
      "hash_header",
    },
    kafka_log = {
      "authentication",
      "keepalive_enabled",
      "security",
    },
    kafka_upstream = {
      "authentication",
      "keepalive_enabled",
      "security",
    },
    openid_connect = {
      "by_username_ignore_case",
      "disable_session",
      "downstream_introspection_jwt_header",
      "downstream_user_info_jwt_header",
      "introspection_accept",
      "introspection_check_active",
      "upstream_introspection_jwt_header",
      "upstream_user_info_jwt_header",
      "userinfo_accept",
      "userinfo_headers_client",
      "userinfo_headers_names",
      "userinfo_headers_values",
      "userinfo_query_args_client",
      "userinfo_query_args_names",
      "userinfo_query_args_values",

      -- Remove elements from fields
      auth_methods = {
        "userinfo",
      },
      ignore_signature = {
        "introspection",
        "userinfo",
      },
      login_methods = {
        "userinfo",
      },
      token_headers_grants = {
        "refresh_token",
      },
    },
    rate_limiting_advanced = {
      "path",
    },
  },

  -- Any dataplane older than 2.7.0
  [2006999999] = {
    -- Enterprise plugins
    forward_proxy = {
      "auth_username",
      "auth_password",
    },
    mocking = {
      "random_examples",
    },
    rate_limiting_advanced = {
      "enforce_consumer_groups",
      "consumer_groups",
    },
  },
}
