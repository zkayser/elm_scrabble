defmodule WordsApi do
	@moduledoc """
	A wrapper for the Words API (https://www.wordsapi.com/).
	This module depends on having a Rapid API account. If you
	want to use this module to make requests to the Words API
	to check whether a words exists or not, you will need to
	sign up [here](https://rapidapi.com/). Free plans are
	available, but you will have to provide payment information.
	If you don't want to use this library, you can swap it our
	for the FakeDictionaryApi module by going to your config
	modules (`dev.exs` and `prod.exs`) and changing out the
	:dictionary_api config:

	```elixir
	config :elm_scrabble, :dictionary_api, FakeDictionaryApi
	```

	To make the calls in this module, you will need to obtain
	an API key from your Rapid API account and set it in an
	environment variable called "WORDS_API_KEY".
	"""
	@api_key System.get_env("WORDS_API_KEY")
	@base_url "https://wordsapiv1.p.mashape.com/words/"
	@headers ["X-Mashape-Key": @api_key, "Accept": "application/json"]

	def get(word, nil), do: raise WordsApiException
	def get(word, api_key) do
		HTTPotion.get(@base_url <> "#{word}", headers: @headers)
	end

	def verify(word) when is_binary(word) do
		get(word, @api_key)
			|> Map.get(:body)
			|> Poison.decode
			|> case do
				{:ok, %{"success" => false}} -> :word_not_found
				{:ok, %{"word" => _word}} -> :word_found
				_ -> {:error, :word_api_request_failed}
			end
	end
	def verify(arg) do
		raise ArgumentException,
		"WordsApi.verify/1 requires a string argument but was called with #{inspect arg}."
	end
end