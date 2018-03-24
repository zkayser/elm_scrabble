defmodule ScrabbleTest do
  use ExUnit.Case

  @default "scrabble"

  describe "Scrabble.raw_score/1" do
    test "empty word scores zero" do
      assert Scrabble.raw_score("") == 0
    end

    test "whitespace scores zero" do
      assert Scrabble.raw_score(" \t\n") == 0
    end

    test "scores very short word" do
      assert Scrabble.raw_score("a") == 1
    end

    test "scores other very short word" do
      assert Scrabble.raw_score("f") == 4
    end

    test "simple word scores the number of letters" do
      assert Scrabble.raw_score("street") == 6
    end

    test "complicated word scores more" do
      assert Scrabble.raw_score("quirky") == 22
    end

    test "scores are case insensitive" do
      assert Scrabble.raw_score("OXYPHENBUTAZONE") == 41
    end

    test "convenient scoring" do
      assert Scrabble.raw_score("alacrity") == 13
    end
  end

  describe "Scrabble.score/1 single play version" do
    test "no multipliers or wildcard characters" do
      scrabble_play = %{"word" => @default, "multipliers" => []}
      assert Scrabble.score(scrabble_play) == {:ok, Scrabble.raw_score(@default)}
    end

    test "double letter multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"DoubleLetter" => ["s"]}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s")}
    end

    test "triple letter multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"TripleLetter" => ["s"]}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s") * 3}
    end

    test "double word multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"DoubleWord" => []}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 2}
    end

    test "triple word multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"TripleWord" => []}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 3}
    end

    test "letter multiplier with word multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"DoubleWord" => []}, %{"TripleLetter" => ~w(s a)}]}
      score = Scrabble.score(scrabble_play)
      expected = Scrabble.raw_score(@default) * 2 + Scrabble.raw_score("s") * 3 + Scrabble.raw_score("a") * 3
      assert score == {:ok, expected}
    end

    test "wildcard" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"Wildcard" => ~w(s)}]}
      assert Scrabble.score(scrabble_play) == {:ok, Scrabble.raw_score(@default) - Scrabble.raw_score("s")}
    end
  end

  describe "Scrabble.score/1 multiple play version" do
    test "multiple plays with valid multipliers" do
      play_one = %{"word" => @default, "multipliers" => [%{"DoubleWord" => []}]}
      play_two = %{"word" => @default, "multipliers" => [%{"TripleWord" => []}]}
      expected = (Scrabble.raw_score(@default) * 2) + (Scrabble.raw_score(@default) * 3)
      assert Scrabble.score(%{"plays" => [play_one, play_two]}) == {:ok, expected}
    end
  end
end