defmodule WordsApiException do
  @message "Must have `WORDS_API_KEY` environment variable set to use the WordsApi module.\n
						If you do not want to sign up for a Rapid API account, go into your dev.exs config
						file and change the value for :dictionary_api to use FakeDictionaryApi instead of
						WordsApi."
  defexception [:message]

  def exception(_value) do
    %WordsApiException{message: @message}
  end
end
