defmodule Scrabble.Board.Supervisor do
  use DynamicSupervisor

  @invalid_process_name "Boards must be created with a string value"
  @registry Registry.Boards

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, _} = Registry.start_link(keys: :unique, name: @registry)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ##############
  # CLIENT API #
  ##############

  def create_board(name) when is_binary(name) do
    spec = %{id: Scrabble.Board, start: {Scrabble.Board, :new, [name]}, restart: :transient}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} when is_pid(pid) ->
        {:ok, name}

      {:error, {:already_started, _pid}} ->
        {:ok, name}

      other ->
        {:error, other}
    end
  end

  def create_board(_), do: {:error, @invalid_process_name}

  def stop_board(name) when is_binary(name) do
    case GenServer.whereis(via_tuple_for(name)) do
      pid when is_pid(pid) -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      nil -> :ok
    end
  end

  def get_pid(name) do
    case GenServer.whereis(via_tuple_for(name)) do
      nil -> {:error, :not_started}
      pid when is_pid(pid) -> pid
    end
  end

  def via_tuple_for(name) do
    {:via, Registry, {@registry, name}}
  end
end
