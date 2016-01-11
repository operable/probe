defmodule Probe do
  @moduledoc """
  Main interface to the Probe event manager.
  """

  @doc """
  Starts the GenEvent manager and adds the `Probe.JSONLogHandler` to
  it.
  """
  def start_link() do
    Probe.Configuration.ensure_log_directory!
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    :ok = GenEvent.add_handler(__MODULE__, Probe.JSONLogHandler, [])
    {:ok, pid}
  end

  @doc """
  Send an event to be logged.
  """
  def notify(event),
    do: GenEvent.notify(__MODULE__, event)

end
