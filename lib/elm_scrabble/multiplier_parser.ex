defmodule MultiplierParser do
	@is_valid_letter ~r([a-zA-Z])

	def parse([]), do: {:ok, []}
	def parse(multipliers) when is_list(multipliers) do
		_parse(multipliers, [])
	end

	def parse(_), do: {:error, :malformed_multipliers}

	defp _parse([], acc), do: {:ok, acc}
	defp _parse([%{"DoubleWord" => []}|tail], acc), do: _parse(tail, [:double_word|acc])
	defp _parse([%{"TripleWord" => []}|tail], acc), do: _parse(tail, [:triple_word|acc])
	defp _parse([%{"DoubleLetter" => letters}|tail], acc) when is_list(letters) do
		letters = Enum.filter(letters, &(&1 =~ @is_valid_letter))
		_parse(tail, [{:double_letter, letters}|acc])
	end
	defp _parse([%{"TripleLetter" => letters}|tail], acc) when is_list(letters) do
		letters = Enum.filter(letters, &(&1 =~ @is_valid_letter))
		_parse(tail, [{:triple_letter, letters}|acc])
	end
	defp _parse([%{"Wildcard" => wildcards}|tail], acc) when is_list(wildcards) do
		wildcards = Enum.filter(wildcards, &(&1 =~ @is_valid_letter))
		_parse(tail, [{:wildcard, wildcards}|acc])
	end
	defp _parse([%{"DoubleWord" => _}|_], _), do: {:error, {:invalid, :double_word}}
	defp _parse([%{"TripleWord" => _}|_], _), do: {:error, {:invalid, :triple_word}}
	defp _parse([%{"DoubleLetter" => _}|_], _), do: {:error, {:invalid, :double_letter}}
	defp _parse([%{"TripleLetter" => _}|_], _), do: {:error, {:invalid, :triple_letter}}
	defp _parse([%{"Wildcard" => _}|_], _), do: {:error, {:invalid, :wildcard}}
	defp _parse([object|_], _), do: {:error, {:invalid_key, hd(Map.keys(object))}}
end