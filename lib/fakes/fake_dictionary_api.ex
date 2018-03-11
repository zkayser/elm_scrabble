defmodule FakeDictionaryApi do
	def verify("not a word"), do: :word_not_found
	def verify(word), do: :word_found
end