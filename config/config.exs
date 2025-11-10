# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :realtime_processor,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :realtime_processor, RealtimeProcessorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RealtimeProcessorWeb.ErrorHTML, json: RealtimeProcessorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RealtimeProcessor.PubSub,
  live_view: [signing_salt: "gHHyBPmP"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  realtime_processor: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../apps/realtime_processor/assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  realtime_processor: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("../apps/realtime_processor", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger_json, :backend,
  formatter: LoggerJSON,
  metadata: [:request_id, :symbol, :topic]

config :phoenix, :json_library, Jason

config :rustler, :crates, [
  rust_processor: [
    path: Path.expand("../../native/rust_processor", __DIR__),
    mode: :release
  ]
]

config :zigler, :zig_nifs,
  zig_nifs: [
    nifs: [
      parse_fix_message: [
        args: [:binary],
        return: :list
      ],
      calculate_checksum: [
        args: [:binary],
        return: :u32
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Sample configuration:
#
#     config :logger, :default_handler,
#       level: :info
#
#     config :logger, :default_formatter,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
