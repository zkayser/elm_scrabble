defmodule Scrabble.BoardTest do
  alias Scrabble.Board
  alias Scrabble.Board.Supervisor
  alias Scrabble.TestData
  use ExUnit.Case

  describe "new/1" do
    test "creates a new board process" do
      id = TestData.generate_board_id()
      Board.new(id)
      assert id |> Supervisor.get_pid() |> Process.alive?()
    end
  end

  describe "stop/1" do
    test "stops the process with the given id" do
      id = TestData.generate_board_id()
      {:ok, id} = Supervisor.create_board(id)
      assert id |> Supervisor.get_pid() |> Process.alive?()
      Board.stop(id)
      assert {:error, :not_started} = Supervisor.get_pid(id)
    end
  end
end