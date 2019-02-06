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
    spec = %{id: Scrabble.Board, start: {Scrabble.Board, :new, []}}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        Registry.register(@registry, name, pid)
        {:ok, name}

      {:error, {:already_started, _pid}} ->
        {:ok, name}

      other ->
        {:error, other}
    end
  end

  def create_board(_), do: {:error, @invalid_process_name}

  def get_pid(name) do
    case Registry.lookup(@registry, name) do
      [] -> {:error, :not_started}
      [{pid, _}] when is_pid(pid) -> pid
      _ -> {:error, :pid_not_found}
    end
  end

  def via_tuple_for(name) do
    {:via, Registry, {@registry, name}}
  end
end
