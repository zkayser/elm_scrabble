defmodule ScrabbleTest do
  use ExUnit.Case

  @default "scrabble"
  @invalid_word "not a word"

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

  # TODO: !IMPORTANT! The score/1 versions taking string keys
  # are in the process of being deprecated in favor of maps
  # with atoms. This is due to the game state moving to be
  # purely encapsulated on the server rather than on the client.
  # The tests below in this describe block are essentially duplicated
  # with the old ones needing to be removed once the migration is
  # complete.
  describe "Scrabble.score/1 single play version" do
    test "no multipliers or wildcard characters" do
      scrabble_play = %{"word" => @default, "multipliers" => []}
      assert Scrabble.score(scrabble_play) == {:ok, Scrabble.raw_score(@default)}
    end

    test "no multipliers or wildcard characters v2" do
      scrabble_play = %{word: @default, multipliers: []}
      assert Scrabble.score(scrabble_play) == {:ok, Scrabble.raw_score(@default)}
    end

    test "double letter multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"DoubleLetter" => ["s"]}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s")}
    end

    test "double letter multiplier v2" do
      scrabble_play = %{word: @default, multipliers: [{:double_letter, ~w(s)}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s")}
    end

    test "triple letter multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"TripleLetter" => ["s"]}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s") * 3}
    end

    test "triple letter multiplier v2" do
      scrabble_play = %{word: @default, multipliers: [{:triple_letter, ~w(s)}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) + Scrabble.raw_score("s") * 3}
    end

    test "double word multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"DoubleWord" => []}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 2}
    end

    test "double word multiplier v2" do
      scrabble_play = %{word: @default, multipliers: [:double_word]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 2}
    end

    test "triple word multiplier" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"TripleWord" => []}]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 3}
    end

    test "triple word multiplier v2" do
      scrabble_play = %{word: @default, multipliers: [:triple_word]}
      score = Scrabble.score(scrabble_play)
      assert score == {:ok, Scrabble.raw_score(@default) * 3}
    end

    test "letter multiplier with word multiplier" do
      scrabble_play = %{
        "word" => @default,
        "multipliers" => [%{"DoubleWord" => []}, %{"TripleLetter" => ~w(s a)}]
      }

      score = Scrabble.score(scrabble_play)

      expected =
        Scrabble.raw_score(@default) * 2 + Scrabble.raw_score("s") * 3 +
          Scrabble.raw_score("a") * 3

      assert score == {:ok, expected}
    end

    test "letter multiplier with word multiplier v2" do
      scrabble_play = %{word: @default, multipliers: [:double_word, {:triple_letter, ~w(s a)}]}

      score = Scrabble.score(scrabble_play)

      expected =
        Scrabble.raw_score(@default) * 2 + Scrabble.raw_score("s") * 3 +
          Scrabble.raw_score("a") * 3

      assert score == {:ok, expected}
    end

    test "wildcard" do
      scrabble_play = %{"word" => @default, "multipliers" => [%{"Wildcard" => ~w(s)}]}

      assert Scrabble.score(scrabble_play) ==
               {:ok, Scrabble.raw_score(@default) - Scrabble.raw_score("s")}
    end

    test "wildcard v2" do
      scrabble_play = %{word: @default, multipliers: [{:wildcard, ~w(s)}]}

      assert Scrabble.score(scrabble_play) ==
               {:ok, Scrabble.raw_score(@default) - Scrabble.raw_score("s")}
    end
  end

  describe "Scrabble.score/1 multiple play version" do
    test "multiple plays with valid multipliers" do
      play_one = %{"word" => @default, "multipliers" => [%{"DoubleWord" => []}]}
      play_two = %{"word" => @default, "multipliers" => [%{"TripleWord" => []}]}
      expected = Scrabble.raw_score(@default) * 2 + Scrabble.raw_score(@default) * 3
      assert Scrabble.score(%{"plays" => [play_one, play_two]}) == {:ok, expected}
    end

    test "Letter multipliers get scored correctly" do
      plays = %{"plays" => [%{"multipliers" => [%{"TripleLetter" => ["Y"]}], "word" => "RAY"}]}
      expected = Scrabble.raw_score("ray") + Scrabble.raw_score("y") * 3
      assert {:ok, expected} == Scrabble.score(plays)
    end
  end

  describe "Scrabble.score/1" do
    test "scores multiple words" do
      play_one = %{word: @default, multipliers: [:double_word]}
      play_two = %{word: @default, multipliers: [:triple_word]}
      expected = Scrabble.raw_score(@default) * 2 + Scrabble.raw_score(@default) * 3
      assert {:ok, expected} == Scrabble.score([play_one, play_two])
    end

    test "returns {:errors, _} with a list of error messages on failure" do
      play_one = %{word: @default, multipliers: [:double_word]}
      play_two = %{word: @invalid_word, multipliers: [:triple_wor]}
      expected = [{:error, "Hey! not a word is not a real word!"}]
      assert {:errors, expected} == Scrabble.score([play_one, play_two])
    end
  end
end
