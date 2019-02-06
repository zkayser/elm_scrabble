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
  end

  defp process_name(), do: "Board_#{Base.encode16(:crypto.strong_rand_bytes(8))}"
end