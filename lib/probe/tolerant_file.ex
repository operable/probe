defmodule Probe.TolerantFile do
  require Logger
  @moduledoc """
  Encapsulates file path, inode, and IO device information together,
  allowing transparent writing to a given path in the face of file
  closing / moving.

  Supports the logging of data to files which will be rotated by
  another system process.

  *NOTE*: As currently coded, this is geared specifically toward the
  needs of Probe (e.g., files are opened in `append` mode, writing
  UTF8, etc.) and no attempt is made to create a complete and
  general-purpose tool.
  """

  @file_modes [:append, :utf8, :sync]

  @typedoc """
  A file that is tolerant of the underlying filesystem device closing
  underneath it.

  # Fields

  * `abs_path`: the absolute path to the file
  * `io_device`: an open file handle to the file
  * `inode`: the inode of the file that `io_device` is pointed at
  """
  @type t :: %__MODULE__{abs_path: String.t,
                         io_device: :file.io_device,
                         inode: term}
  defstruct [abs_path: nil,
             io_device: nil,
             inode: nil]

  @doc """
  Constructor function.

  When given a file path, a new `#{inspect __MODULE__}` instance is
  created.

  When given a `#{inspect __MODULE__}` instance, if the current inode
  associated with the path does not match the inode of the instance,
  the IO device of the instance is closed and a "fresh" instance is
  returned.

  Always opens files with the modes `#{inspect @file_modes}`. See
  `File.open/2` for details.
  """
  def open(path) when is_binary(path) do
    abs_path = Path.expand(path)
    case File.open(abs_path, @file_modes) do
      {:ok, io_device} ->
        :ok = :file.sync(io_device)
        {:ok, inode} = inode(abs_path)
        {:ok, %__MODULE__{abs_path: abs_path, io_device: io_device, inode: inode}}
      {:error, _}=error ->
        error
    end
  end
  def open(%__MODULE__{inode: inode, io_device: io_device}=file) do
    :ok = :file.sync(io_device)
    case inode(file.abs_path) do
      {:ok, ^inode} ->
        {:ok, file}
      _ ->
        close(file)
        open(file.abs_path)
    end
  end

  @doc """
  Closes the underlying IO device of `file`.
  """
  def close(%__MODULE__{}=file),
    do: File.close(file.io_device)

  @doc """
  Wrapper for `IO.puts/2`.

  Writes `content` to `file`, respecting underlying file closings. A
  newline is appended after `content`.

  Returns a possibly-new instance of `#{inspect __MODULE__}`.
  """
  def puts(%__MODULE__{}=file, content) do
    {:ok, refreshed} = open(file)
    :ok = IO.puts(refreshed.io_device, content)
    {:ok, refreshed}
  end

  # Returns the inode of the file at `path`, or `nil` if the file is
  # not accessible.
  defp inode(path) do
    case File.stat(path) do
      {:ok, %File.Stat{inode: inode}} ->
        {:ok, inode}
      _ ->
        nil
    end
  end

end
