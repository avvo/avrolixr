defmodule Avrolixr.Codec.Pairs do
  @type key_t :: charlist
  @type value_t :: binary | number | boolean | t # TODO: differentiate between '' and [] possible?
  @type pair_t :: {key_t, value_t}
  @type t :: list(pair_t)
  @type map_key_t :: String.t
  @type map_value_t :: any

  @spec to_map(t) :: map
  def to_map(pairs), do: to_map(%{}, pairs)

  @spec to_map(map, t) :: map
  defp to_map(acc, []), do: acc
  defp to_map(acc, [{k, v} | tail]) do
    acc
    |> Map.put(key_to_map_key(k), value_to_map_value(v))
    |> to_map(tail)
  end

  @spec key_to_map_key(key_t) :: map_key_t
  defp key_to_map_key(k), do: k |> to_string

  @spec value_to_map_value(value_t) :: map_value_t
  defp value_to_map_value(''), do: ""
  defp value_to_map_value(v) when is_list(v), do: list_to_map_value(hd(v), v)
  defp value_to_map_value(v), do: v

  defp list_to_map_value(h, list) when is_number(h), do: to_string(list)
  defp list_to_map_value(_, list) when is_list(list) do
    case list do
      [{_, _} | _] -> to_map(list)
      _ -> list |> Enum.map(&value_to_map_value/1)
    end
  end
end
