defmodule Avrolixr.Codec do
  alias Avrolixr.Codec.Json
  alias Avrolixr.Codec.Pairs

  @type error_t :: {:error, String.t}
  @type avro_t :: binary
  @type schema_t :: String.t | map
  @type type_t :: charlist
  @type value_t :: any

  @spec decode(avro_t) :: {:ok, value_t} | error_t
  def decode(v_avro) do
    with tuple <- :avro_ocf.decode_stream(ocf_schema, v_avro),
         {[{'magic', _}, {'meta', meta}, {'sync', sync}], tail} <- tuple,
         schema_json <- meta
           |> Enum.at(1)
           |> elem(1),
         {schema, store} <- make_schema_and_store(schema_json),
         v <- store
           |> :avro_ocf.decode_blocks(schema, sync, tail, [])
           |> hd
           |> Pairs.to_map do
      {:ok, v}
    end
  end

  @spec encode(value_t, schema_t, type_t, list) :: {:ok, avro_t} | error_t
  def encode(v, schema_json, type, opts \\ []) do
    msg = !Keyword.get(opts, :strict)
      || Json.robust?(v)
      || "Not JSON-robust: #{inspect v}"
    do_encode(v, schema_json, type, msg)
  end

  def round_trip(v, schema_json, type, opts \\ []) do
    with {:ok, v_avro} <- encode(v, schema_json, type, opts), do: decode(v_avro)
  end

  @spec robust?(any, schema_t, type_t) :: boolean
  def robust?(v, schema_json, type, opts \\ []) do
    try do
      v == v |> round_trip!(schema_json, type, opts)
    rescue _ -> false
    end
  end

  def encode!(v, schema_json, type, opts \\ []) do
    {:ok, v_avro} = v |> encode(schema_json, type, opts)
    v_avro
  end

  def decode!(v_avro) do
    {:ok, v} = decode(v_avro)
    v
  end

  def round_trip!(v, schema_json, type, opts \\ []) do
    {:ok, v_after} = v |> round_trip(schema_json, type, opts)
    v_after
  end

  defp do_encode(v, schema_json, type, true) do
    {store, hdr, sync} = make_store_hdr_and_sync(schema_json)

    term = v
      |> Json.encode!
      |> :avro_json_decoder.decode_value(type, store, [{:is_wrapped, false}, {:json_decoder, :mochijson3}])

    bytes = :avro_binary_encoder.encode(store, type, term)
      |> :erlang.iolist_to_binary

    io_data = encode_long(1) ++ encode_bytes(bytes) ++ [sync]

    data_bytes = io_data
      |> :erlang.list_to_binary

    {:ok, hdr <> data_bytes}
  end
  defp do_encode(_, _, _, msg), do: {:error, msg}

  defp make_store_hdr_and_sync(schema_json) do
    {schema, store} = make_schema_and_store(schema_json)

    {:header, magic, meta, sync} = :avro_ocf.make_header(schema)
    x = [{'magic', magic}, {'meta', meta}, {'sync', sync}]

    hdr = :avro_record.new(ocf_schema, x)
      |> :avro_binary_encoder.encode_value
      |> :erlang.list_to_binary

    {store, hdr, sync}
  end

  defp make_schema_and_store(schema_json) do
    {
      :avro_json_decoder.decode_schema(schema_json),
      :avro_schema_store.import_schema_json(schema_json, :avro_schema_store.new)
    }
  end

  defp encode_long(long) do
    [long |> :avro_primitive.long |> :avro_binary_encoder.encode_value]
  end

  defp encode_bytes(bytes), do: encode_long(byte_size(bytes)) ++ [bytes]

  defp ocf_schema, do: :avro_ocf.ocf_schema
end
