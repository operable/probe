defmodule Probe.JSONLogHandler do
  @moduledoc """
  Logs events as structured JSON maps to a file. Designed to work with
  log rotation utilities, tolerating the log file being moved or
  deleted from underneath it.
  """

  use GenEvent
  require Logger

  alias Probe.TolerantFile

  @log_file "events.log"

  @type state :: %__MODULE__{log_file: Probe.TolerantFile.t}
  defstruct [log_file: nil]

  def init(_) do
    path = log_path
    Logger.info("Attempting to open JSON-formatted event log file `#{path}`")
    case TolerantFile.open(path) do
      {:ok, file} ->
        Logger.info("Logging JSON-formatted event stream to `#{path}`")
        {:ok, %__MODULE__{log_file: file}}
      {:error, _}=error ->
        Logger.error("Could not open JSON event log file `#{path}`: #{inspect error}")
        error
    end
  end

  def handle_event(event, state) when is_map(event) do
    Logger.warn("EVENT: #{inspect event}")
    event |> inspect |> handle_event(state)
  end
  def handle_event(event, state) when is_binary(event) do
    {:ok, log_file} = TolerantFile.puts(state.log_file, event)
    {:ok, %{state | log_file: log_file}}
  end

  defp log_path,
    do: Path.join(Probe.Configuration.log_directory, @log_file)

end
