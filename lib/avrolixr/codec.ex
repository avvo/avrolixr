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
    case decode_stream(v_avro) do
      { [ {'magic', _}, {'meta', [_, {_, schema_json}]}, {'sync', sync} ], tail } ->
        {:ok, decode_blocks(schema_json, sync, tail) |> hd |> Pairs.to_map}
      error -> {:error, "Could not decode binary stream, got #{inspect error}"}
    end
  end

  @spec encode(value_t, schema_t, type_t, list) :: {:ok, avro_t} | error_t
  def encode(v, schema_json, type, opts \\ []) do
    msg = !Keyword.get(opts, :strict)
      || Json.robust?(v)
      || "Not JSON-robust: #{inspect v}"
    do_encode(v, schema_json, type, msg)
  end

  @spec round_trip(value_t, schema_t, type_t, list) :: {:ok, value_t} | error_t
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

  @spec encode!(value_t, schema_t, type_t, list) :: avro_t
  def encode!(v, schema_json, type, opts \\ []) do
    {:ok, v_avro} = v |> encode(schema_json, type, opts)
    v_avro
  end

  @spec decode!(avro_t) :: value_t
  def decode!(v_avro) do
    {:ok, v} = decode(v_avro)
    v
  end

  @spec round_trip!(value_t, schema_t, type_t, list) :: value_t
  def round_trip!(v, schema_json, type, opts \\ []) do
    {:ok, v_after} = v |> round_trip(schema_json, type, opts)
    v_after
  end

  defp do_encode(v, schema_json, type, true) do
    store = make_store(schema_json)
    {hdr, sync} = make_hdr_and_sync(schema_json)

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

  defp make_hdr_and_sync(schema_json) do
    schema = make_schema(schema_json)

    {:header, magic, meta, sync} = :avro_ocf.make_header(schema)

    hdr = :avro_record.new(ocf_schema(), [{'magic', magic}, {'meta', meta}, {'sync', sync}])
      |> :avro_binary_encoder.encode_value
      |> :erlang.list_to_binary

    {hdr, sync}
  end

  defp make_schema(schema_json) do
    :avro_json_decoder.decode_schema(schema_json)
  end

  defp make_store(schema_json) do
    Avrolixr.Store.import_schema(schema_json)
  end

  defp encode_long(long) do
    [long |> :avro_primitive.long |> :avro_binary_encoder.encode_value]
  end

  defp encode_bytes(bytes), do: encode_long(byte_size(bytes)) ++ [bytes]

  defp ocf_schema, do: :avro_ocf.ocf_schema

  defp decode_stream(v_avro), do: :avro_ocf.decode_stream(ocf_schema(), v_avro)

  defp decode_blocks(schema_json, sync, tail) do
    :avro_ocf.decode_blocks(make_store(schema_json), make_schema(schema_json), sync, tail, [])
  end

end
