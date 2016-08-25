defmodule Avrolixr.Codec.Json do
  @moduledoc """
  Indirection to a JSON parser. Currently using Poison.
  """

  defdelegate encode!(v), to: Poison
  defdelegate decode!(v), to: Poison
  defdelegate encode(v), to: Poison
  defdelegate decode(v), to: Poison

  @spec canonical!(any) :: String.t
  def canonical!(v), do: [v] |> encode! |> decode! |> hd

  @spec robust?(any) :: boolean
  def robust?(v) do
   try do
     v == canonical!(v)
   rescue _ in [Poison.EncodeError] -> false
   end
  end
end
