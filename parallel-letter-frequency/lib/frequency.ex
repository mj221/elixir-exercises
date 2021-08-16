defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do
    texts
    |> Task.async_stream(&calculate_letters/1, max_concurrency: workers)
    |> Enum.to_list
    |> Enum.flat_map(fn {:ok, result} -> result |> Map.to_list end)
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(map, acc, fn _x, count1, count2 -> count1 + count2 end)
    end)
  end

  defp calculate_letters(texts) do
  Regex.scan(~r/\p{L}{1}/u, String.downcase(texts))
  texts
    |> String.downcase
    |> String.graphemes
    |> Enum.reduce(%{}, fn letter, acc->
    Map.update(acc, letter, 1, fn x -> x+1 end)
    end)
  end
end
