defmodule SimpleLoggerSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children =
      for id <- 1..50 do
        %{
          id: id,
          start: {SimpleLogger, :start_link, [id]},
          restart: :permanent,
          type: :worker
        }
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
