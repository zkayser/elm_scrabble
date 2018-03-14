defmodule Leaderboard do
	use Agent

	def start_link() do
		Agent.start_link(&Map.new/0, name: __MODULE__)
	end

	def update(name, score) do
		Agent.update(__MODULE__, &_update(&1, name, score))
	end

	def put(player) do
		Agent.update(__MODULE__, &Map.put(&1, player, 0))
	end

	def top_scorers(count \\ 5) do
		Agent.get(__MODULE__, fn state -> _top_scorers(state, count) end )
	end

	defp _update(state, name, score) do
		Map.update(state, name, 0, fn old_score -> old_score + score end)
	end

	defp _top_scorers(state, count) do
		case length(Map.keys(state)) > 1 do
			true ->
				state
				|> Enum.sort(fn {_, value_1}, {_, value_2} -> value_1 > value_2 end)
				|> Enum.take(count)
				|> Enum.map(fn {name, score} -> %{user: name, score: score} end)
			false ->
				Map.to_list(state)
				|> Enum.map(fn {name, score} -> %{user: name, score: score} end)
		end
	end

end