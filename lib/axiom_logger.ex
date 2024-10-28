defmodule AxiomLogger do
  @moduledoc """
  A Logger backend to send logs to Axiom.
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

  # Handles synchronous calls from Logger (e.g., configuration)
  def handle_call({:configure, _options}, state) do
    {:ok, :ok, state}
  end

  def handle_call(:flush, state) do
    {:ok, :ok, state}
  end

  # Handles log events
  def handle_event({level, _gl, {Logger, msg, _timestamp, metadata}}, state)
      when level in [:info, :error, :warn, :debug] do
    producer_id = Keyword.get(metadata, :producer)

    IO.puts(producer_id)

    log_entry = %{
      level: to_string(level),
      message: to_string(msg),
      producer_id: producer_id
    }

    send_log_to_axiom(log_entry)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  # Handles any other events
  def handle_event(_event, state) do
    {:ok, state}
  end

  # Handles unexpected messages
  def handle_info(_msg, state) do
    {:ok, state}
  end

  # Cleans up when the backend is terminated
  def terminate(_reason, _state) do
    :ok
  end

  defp send_log_to_axiom(log_entry) do
    headers = [
      {"Authorization", "Bearer #{System.get_env("AXIOM_API_TOKEN")}"},
      {"Content-Type", "application/json"}
    ]

    body = JSON.encode!([log_entry])

    case Req.post(@api_endpoint, headers: headers, body: body) do
      {:ok, res} ->
        case res.status do
          200 -> IO.puts("Log sent to Axiom successfully")
          400 -> Logger.error("Bad request: #{inspect(res.body)}")
          403 -> Logger.error("Forbidden: #{inspect(res.body)}")
          _ -> Logger.error("Error sending log to Axiom: #{inspect(res)}")
        end

      {:error, error} ->
        Logger.error("Error sending log to Axiom: #{inspect(error)}")
    end
  end
end
