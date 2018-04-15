defmodule Scrabble do
  alias Scrabble.Multiplier

  @dictionary_api Application.get_env(:elm_scrabble, :dictionary_api)
  @type play() :: %{word: String.t(), multipliers: [multipliers]}
  @type plays() :: [play()]
  @type multipliers :: Multiplier.t() | {Multiplier.t(), [String.t()]}
  @type result :: {:ok, pos_integer()} | {:error, String.t()} | {:errors, [String.t()]}

  @spec score(play() | plays()) :: result()
  def score(plays) when is_list(plays) do
    results = for play <- plays, do: score(play)

    case Enum.any?(results, fn {status, _} -> status == :error end) do
      true -> {:errors, Enum.filter(results, fn {status, _} -> status == :error end)}
      false -> {:ok, Enum.reduce(results, 0, fn {_, score}, acc -> acc + score end)}
    end
  end

  def score(%{word: word, multipliers: multipliers}) do
    verify_word(word, multipliers)
  end

  # This version of score/1 is deprecated
  def score(%{"plays" => plays}) when is_list(plays) do
    results = for play <- plays, do: score(play)

    case Enum.any?(results, fn {status, _} -> status == :error end) do
      true -> {:errors, Enum.filter(results, fn {status, _} -> status == :error end)}
      false -> {:ok, Enum.reduce(results, 0, fn {_, score}, acc -> acc + score end)}
    end
  end

  def score(%{"word" => word, "multipliers" => multipliers}) do
    case MultiplierParser.parse(multipliers) do
      {:error, _} -> {:error, "It looks like you have some invalid multipliers."}
      {:ok, multipliers} -> verify_word(word, multipliers)
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
    current_score - Enum.reduce(letters, 0, fn letter, acc -> get_score(letter) + acc end)
  end

  defp handle_multiplier({:double_letter, letters}, current_score) when is_list(letters) do
    Enum.reduce(letters, 0, fn letter, acc -> get_score(letter) + acc end) + current_score
  end

  defp handle_multiplier({:triple_letter, letters}, current_score) when is_list(letters) do
    Enum.reduce(letters, 0, fn letter, acc -> get_score(letter) * 3 + acc end) + current_score
  end

  defp handle_multiplier(:double_word, current_score), do: current_score * 2
  defp handle_multiplier(:triple_word, current_score), do: current_score * 3
  defp handle_multiplier(_, current_score), do: current_score

  defp verify_word(word, multipliers) do
    case @dictionary_api.verify(word) do
      :word_found -> {:ok, _score(word, multipliers)}
      :word_not_found -> {:error, "Hey! #{word} is not a real word!"}
      {:error, reason} -> {:error, reason}
    end
  end
end
