defmodule SimpleLogger do
  use GenServer
  require Logger

  @imeis [
    "IMEI12345678901",
    "IMEI12345678902",
    "IMEI12345678903",
    "IMEI12345678904",
    "IMEI12345678905",
    "IMEI12345678906",
    "IMEI12345678907",
    "IMEI12345678908",
    "IMEI12345678909",
    "IMEI12345678910"
  ]

  # Start the GenServer
  def start_link(id) do
    GenServer.start_link(__MODULE__, %{id: id}, name: via_tuple(id))
  end

  def init(state) do
    schedule_log()
    {:ok, state}
  end

  # Handle scheduled logging event
  def handle_info(:log_message, state) do
    log_random_message(state.id)
    schedule_log()
    {:noreply, state}
  end

  # Helper function to log a message with a random IMEI, type, timestamp, and hex data
  defp log_random_message(id) do
    imei = Enum.random(@imeis)
    type = Enum.random(["REG", "ACK", "ERR"])
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    hex_data = :crypto.strong_rand_bytes(16) |> Base.encode64()

    # Log the message in a comma-separated format
    Logger.info("+#{type}:#{imei},#{timestamp},#{hex_data}$", [{:producer, id}])
  end

  # Schedule the next log event with a random interval between 1 and 10 minutes
  defp schedule_log do
    random_interval = :rand.uniform(10) * :timer.minutes(1)
    Process.send_after(self(), :log_message, random_interval)
  end

  defp via_tuple(id), do: {:via, Registry, {SimpleLoggerRegistry, id}}
end
