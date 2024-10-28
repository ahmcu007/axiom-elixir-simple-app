# config/config.exs
import Config

config :logger, backends: [:console, AxiomLogger]

config :logger, AxiomLogger, level: :info
