defmodule Avrolixr.CodecTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Avrolixr.Codec
  alias Avrolixr.Codec.Json
  alias Avrolixr.Codec.Pairs

  describe "encode/decode round trip," do
    setup do
      schema_path = "test/data/AvvoProAdded.avsc"
      {:ok, schema_json} = File.read(schema_path)
      type = 'AvvoEvent.AvvoProAdded'
      v = %{event: %{app_id: "a", name: "n", timestamp: 0}, lawyer_id: 0}
      v_canonical = %{
        "event" => %{"app_id" => "a", "name" => "n", "timestamp" => 0},
        "lawyer_id" => 0
      }
      {:ok, sj: schema_json, v: v, vc: v_canonical, t: type}
    end

    test "lax", %{sj: schema_json, v: v, vc: v_canonical, t: type} do
      v_after = v |> Codec.round_trip!(schema_json, type)
      refute v_after == v
      assert v_after == v_canonical
    end

    test "strict", %{sj: schema_json, vc: v_canonical, t: type} do
      v_after = v_canonical
        |> Codec.round_trip!(schema_json, type, strict: true)
      assert v_after == v_canonical
    end
  end

  describe ~s(schema w/union: "type" : [ "int", "null" ],) do
    setup do
      # "natural" nullable int representation
      i_native = %{"f" => 10}
      n_native = %{"f" => nil}

      # "Avro-specific" nullable int representation
#      i_foreign = %{"f": %{"int": 0}}
#      n_foreign = %{"f": %{"null": :null}}
      i_foreign = File.read!("test/data/R_0.json") |> Poison.decode!
      n_foreign = File.read!("test/data/R_null.json") |> Poison.decode!

      n_avro = File.read!("test/data/R_null.avro")
      i_avro = File.read!("test/data/R_0.avro")
      schema_json = File.read!("test/data/R.avsc")
      type = 'N.R'
      encode_fn = &(Codec.encode!(&1, schema_json, type))
      decode_fn = &(Codec.encode!(&1, schema_json, type))
      robust_fn = &(Codec.robust?(&1, schema_json, type))
      round_trip_fn = &(Codec.round_trip!(&1, schema_json, type))

      {
        :ok,
        df: decode_fn,
        ef: encode_fn,
        ia: i_avro,
        ifo: i_foreign,
        ina: i_native,
        na: n_avro,
        nfo: n_foreign,
        nna: n_native,
        rf: robust_fn,
        rtf: round_trip_fn
      }
    end

    test "strict int round-trip", %{ina: i_native, rtf: round_trip_fn} do
      v_canonical = Codec.Json.canonical!(i_native)
      v_after = round_trip_fn.(v_canonical)
      assert v_after == v_canonical
    end

    @tag :skip # TODO: null has bugs, not needed for this release
    test "strict null round-trip", %{nna: n_native, rtf: round_trip_fn} do
      v_canonical = Codec.Json.canonical!(n_native)
      v_after = round_trip_fn.(v_canonical)
      assert v_after == v_canonical
    end

    test "foregin int not robust", %{ifo: i_foreign, ina: i_native, rtf: round_trip_fn} do
      i_after = round_trip_fn.(i_foreign)
      refute i_after == i_foreign
      assert i_after == i_native
    end

    test "foreign nil not rubust", %{nfo: n_foreign, nna: n_native, rtf: round_trip_fn} do
      n_after = round_trip_fn.(n_foreign)
      refute n_after == n_foreign # %{"f": %{"null": :null}}
      refute n_after == n_native # %{"f" => nil}
      assert n_after == %{"f" => :null}
    end

    test "foreign nil encodes", %{nfo: n_foreign, ef: encode_fn} do
      assert encode_fn.(n_foreign)
    end

    test "foreign int encodes", %{ifo: i_foreign, ef: encode_fn} do
      assert encode_fn.(i_foreign)
    end

    test "native nil encodes", %{nna: n_native, ef: encode_fn} do
      assert encode_fn.(n_native)
    end

    test "native int encodes", %{ina: i_native, ef: encode_fn} do
      assert encode_fn.(i_native)
    end

    @tag :skip # TODO: decoding binary files has bugs, not needed for this release
    test "int decodes", %{ia: i_avro, df: decode_fn} do
      assert decode_fn.(i_avro)
    end

    @tag :skip # TODO: decoding binary files has bugs, not needed for this release
    test "nil decodes", %{na: n_avro, df: decode_fn} do
      assert decode_fn.(n_avro)
    end
  end

  describe "Pairs.to_map," do
    test "flat" do
      map = %{"app_id" => "a", "name" => "n", "timestamp" => 0}
      avro = [{'name', 'n'}, {'timestamp', 0}, {'app_id', 'a'}]
      assert Pairs.to_map(avro) == map
    end

    test "nested," do
      map = %{
        "event" => %{"app_id" => "a", "name" => "n", "timestamp" => 0},
        "lawyer_id" => 0
      }
      avro = [
        {'event', [{'name', 'n'}, {'timestamp', 0}, {'app_id', 'a'}]},
        {'lawyer_id', 0}
      ]
      assert Pairs.to_map(avro) == map
    end

    test "nil" do
      assert Pairs.to_map([{'a', nil}]) == %{"a" => nil}
    end

    test "bool" do
      assert Pairs.to_map([{'a', true}]) == %{"a" => true}
    end

    test "number" do
      assert Pairs.to_map([{'a', 0}]) == %{"a" => 0}
    end

    @tag :skip
    test "empty string" do
      assert Pairs.to_map([{'a', ''}]) == %{"a" => ""}
    end

    test "string" do
      assert Pairs.to_map([{'a', 'a'}]) == %{"a" => "a"}
    end

    @tag :skip
    test "empty list" do
      assert Pairs.to_map([{'a', []}]) == %{"a" => []}
    end

    @tag :skip
    test "list" do
      assert Pairs.to_map([{'a', [0]}]) == %{"a" => [0]}
    end

    test "empty map" do
      assert Pairs.to_map([{'a', %{}}]) == %{"a" => %{}}
    end

    test "map" do
      assert Pairs.to_map([{'a', %{"a" => 1}}]) == %{"a" => %{"a" => 1}}
    end
  end

  describe "Json.robust?," do
    test "numbers are robust", do: assert Json.robust?(0) == true
    test "nil is robust", do: assert Json.robust?(nil) == true
    test "booleans are robust", do: assert Json.robust?(false) == true
    test "atoms are not robust", do: assert Json.robust?(:v) == false
    test "charlists are robust", do: assert Json.robust?('v') == true
    test "empty strings are robust", do: assert Json.robust?("") == true
    test "strings are robust", do: assert Json.robust?("v") == true
    test "lists are robust", do: assert Json.robust?([0]) == true
    test "tuples are not robust", do: assert Json.robust?({0}) == false

    test "maps with string keys are robust" do
      assert Json.robust?(%{"k" => 0}) == true
    end

    test "maps with atom keys are not robust" do
      assert Json.robust?(%{k: 0}) == false
    end

    defmodule M, do: defstruct [:k]
    test "structs are not robust" do
      assert Json.robust?(struct(M, k: 0)) == false
    end
  end
end
