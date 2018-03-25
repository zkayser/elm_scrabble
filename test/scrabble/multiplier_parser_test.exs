defmodule MultiplierParserTest do
	use ExUnit.Case

	describe "MultiplierParser.parse/1" do
		test "No multipliers" do
			assert {:ok, []} = MultiplierParser.parse([])
		end

		test "DoubleWord" do
			assert {:ok, [:double_word]} = MultiplierParser.parse([%{"DoubleWord" => []}])
			assert {:error, {:invalid, :double_word}} = MultiplierParser.parse([%{"DoubleWord" => ["a"]}])
		end

		test "TripleWord" do
			assert {:ok, [:triple_word]} = MultiplierParser.parse([%{"TripleWord" => []}])
			assert {:error, {:invalid, :triple_word}} = MultiplierParser.parse([%{"TripleWord" => ["a"]}])
		end

		test "DoubleLetter" do
			assert {:ok, [double_letter: ~w(a b)]} = MultiplierParser.parse([%{"DoubleLetter" => ["a", "b"]}])
			assert {:ok, [double_letter: ~w(a b)]} = MultiplierParser.parse([%{"DoubleLetter" => ["A", "B"]}])
			assert {:ok, [double_letter: ~w(a)]} = MultiplierParser.parse([%{"DoubleLetter" => ["a", "鷹"]}])
		end

		test "TripleLetter" do
			assert {:ok, [triple_letter: ~w(a b)]} = MultiplierParser.parse([%{"TripleLetter" => ["a", "b"]}])
			assert {:ok, [triple_letter: ~w(a b)]} = MultiplierParser.parse([%{"TripleLetter" => ["A", "B"]}])
			assert {:ok, [triple_letter: ~w(a)]} = MultiplierParser.parse([%{"TripleLetter" => ["a", "鷹"]}])
		end

		test "Wildcard" do
			assert {:ok, [wildcard: ~w(a b)]} = MultiplierParser.parse([%{"Wildcard" => ["a", "b"]}])
			assert {:ok, [wildcard: ~w(a b)]} = MultiplierParser.parse([%{"Wildcard" => ["A", "B"]}])
			assert {:ok, [wildcard: ~w(a)]} = MultiplierParser.parse([%{"Wildcard" => ["a", "鷹"]}])
		end

		test "Invalid key" do
			assert {:error, {:invalid_key, "Gibberish"}} = MultiplierParser.parse([%{"Gibberish" => ["blah"]}])
		end

		test "Multiple valid multipliers given" do
			multipliers = [%{"DoubleWord" => []}, %{"TripleLetter" => ["a", "b"]}, %{"Wildcard" => ["a"]}]
			assert {:ok, expected} = MultiplierParser.parse(multipliers)
			assert expected == [:double_word, wildcard: ~w(a), triple_letter: ~w(a b)]
		end

		test "Multiple invalid multipliers given" do
			multipliers = [%{"TripleWord" => ["a"], "DoubleWord" => ["a"]}]
			assert {:error, {:invalid, :double_word}} = MultiplierParser.parse(multipliers)
		end
	end
end