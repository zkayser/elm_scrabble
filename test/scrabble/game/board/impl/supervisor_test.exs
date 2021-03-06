defmodule Scrabble.Board.SupervisorTest do
  use ExUnit.Case
  alias Scrabble.Board.Supervisor

  test "it exists" do
    assert Process.whereis(Supervisor) |> Process.alive?()
  end

  describe "create_board/1" do
    test "only accepts string values" do
      assert {:ok, _} = Supervisor.create_board(process_name())
      assert {:error, _} = Supervisor.create_board(1)
      assert {:error, _} = Supervisor.create_board(nil)
    end

    test "returns the process name when starting the process" do
      name = process_name()
      assert {:ok, name} = Supervisor.create_board(name)
    end

    test "returns the process name when the process has already been started" do
      name = process_name()
      Supervisor.create_board(name)
      assert {:ok, name} = Supervisor.create_board(name)
    end

    test "creates a process associated with the given name" do
      assert {:ok, name} = Supervisor.create_board(process_name())

      assert name
             |> Supervisor.get_pid()
             |> Process.alive?()
    end

    test "prevents multiple processes with the same name from being started" do
      name = process_name()
      assert {:ok, name} = Supervisor.create_board(name)
      pid = Supervisor.get_pid(name)
      assert {:ok, name} = Supervisor.create_board(name)
      assert pid == Supervisor.get_pid(name)
    end

    test "creates different processes for boards with different names" do
      assert {:ok, name_1} = Supervisor.create_board(process_name())
      assert {:ok, name_2} = Supervisor.create_board(process_name())

      refute Supervisor.get_pid(name_1) == Supervisor.get_pid(name_2)
    end
  end

  describe "stop_board/1" do
    test "stops a child board process and removes its pid from the registry" do
      assert {:ok, board_id} = Supervisor.create_board(process_name())
      pid = Supervisor.get_pid(board_id)
      assert is_pid(pid)
      :ok = Supervisor.stop_board(board_id)
      assert {:error, :not_started} = Supervisor.get_pid(board_id)
    end
  end

  defp process_name(), do: "Board_#{Base.encode16(:crypto.strong_rand_bytes(8))}"
end
