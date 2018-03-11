defmodule Scrabble do

	@dictionary_api Application.get_env(:elm_scrabble, :dictionary_api)

	def score(%{"word" => word, "multipliers" => multipliers}) do
		case @dictionary_api.verify(word) do
			:word_found -> _score(word, multipliers)
			:word_not_found -> {:error, "Hey! I'm pretty sure #{word} is not a real word."}
			{:error, reason} -> {:error, reason}
		end
	end

	def raw_score(word) when is_binary(word) do
		word
		|> String.trim()
		|> String.downcase()
		|> String.codepoints()
		|> Enum.reduce(0, &add_score(&1, &2))
	end

	defp _score(word, multipliers) do
		Enum.reduce(multipliers, raw_score(word), &handle_multiplier(&1, &2))
	end

	defp get_score(letter) when letter in ~w(a e i o u l n r s t), do: 1
	defp get_score(letter) when letter in ~w(d g), do: 2
	defp get_score(letter) when letter in ~w(b c m p), do: 3
	defp get_score(letter) when letter in ~w(f h v w y), do: 4
	defp get_score(letter) when letter == "k", do: 5
	defp get_score(letter) when letter in ~w(j x), do: 8
	defp get_score(letter) when letter in ~w(q z), do: 10
	defp get_score(_), do: 0

	defp add_score(letter, current_score) do
		get_score(letter) + current_score
	end

	defp handle_multiplier({:wildcard, letters}, current_score) when is_list(letters) do
	 current_score - Enum.reduce(letters, 0, fn (letter, acc) -> get_score(letter) + acc end)
	end

	defp handle_multiplier({:double_letter, letters}, current_score) when is_list(letters) do
		Enum.reduce(letters, 0, fn (letter, acc) ->  get_score(letter) + acc end) + current_score
	end

	defp handle_multiplier({:triple_letter, letters}, current_score) when is_list(letters) do
		Enum.reduce(letters, 0, fn (letter, acc) -> get_score(letter) * 3 + acc end) + current_score
	end

	defp handle_multiplier(:double_word, current_score), do: current_score * 2
	defp handle_multiplier(:triple_word, current_score), do: current_score * 3
	defp handle_multiplier(_, current_score), do: current_score
end