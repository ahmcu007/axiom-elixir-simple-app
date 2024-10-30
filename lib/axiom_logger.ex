defmodule AxiomLogger do
  @moduledoc """
  A Logger backend to send structured JSON logs to Axiom.
  """

  use GenServer
  require Logger
  alias Jason, as: JSON

  @api_endpoint "https://api.axiom.co/v1/datasets/elixir-messages/ingest"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:configure, _options}, state), do: {:ok, :ok, state}
  def handle_call(:flush, state), do: {:ok, :ok, state}

  def handle_event({level, _gl, {Logger, msg, timestamp, metadata}}, state)
      when level in [:info, :error, :warn, :debug] do
    log_entry = %{
      level: to_string(level),
      message: to_string(msg),
      timestamp: format_timestamp(timestamp),
      metadata: Map.new(metadata, fn {k, v} -> {k, inspect(v)} end)
    }

    send_log_to_axiom(log_entry)
    {:ok, state}
  end

  def handle_event(:flush, state), do: {:ok, state}
  def handle_event(_event, state), do: {:ok, state}

  # Updated handle_info to safely ignore Logger.Backends.Config messages
  def handle_info({Logger.Backends.Config, :update_counter}, state), do: {:ok, state}
  def handle_info(_msg, state), do: {:ok, state}

  def terminate(_reason, _state), do: :ok

  defp format_timestamp({date, {hour, minute, second, _}}) do
    NaiveDateTime.from_erl!({date, {hour, minute, second}})
    |> NaiveDateTime.to_iso8601()
  end

  defp send_log_to_axiom(log_entry) do
    headers = [
      {"Authorization", "Bearer #{System.get_env("AXIOM_API_TOKEN")}"},
      {"Content-Type", "application/json"}
    ]

    body = JSON.encode!([log_entry])

    case Req.post(@api_endpoint, headers: headers, body: body) do
      {:ok, res} when res.status == 200 -> IO.puts("Log sent to Axiom successfully")
      {:ok, res} -> Logger.error("Failed with status #{res.status}: #{inspect(res.body)}")
      {:error, error} -> Logger.error("Error sending log to Axiom: #{inspect(error)}")
    end
  end
end
