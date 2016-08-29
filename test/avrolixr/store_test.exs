defmodule Avrolixr.StoreTest do
  @moduledoc false
  use ExUnit.Case, async: true

  test "import_schema imports json schema to store" do
    schema_path = "test/data/AvvoProAdded.avsc"
    {:ok, schema_json} = File.read(schema_path)
    store = Avrolixr.Store.import_schema(schema_json)
    assert  {:ok, _} = :avro_schema_store.lookup_type('AvvoEvent.AvvoProAdded', store)
  end

  test "importing same schema twice doesn't fail" do
    schema_path = "test/data/AvvoProAdded.avsc"
    {:ok, schema_json} = File.read(schema_path)
    store = Avrolixr.Store.import_schema(schema_json)
    store = Avrolixr.Store.import_schema(schema_json)
    assert  {:ok, _} = :avro_schema_store.lookup_type('AvvoEvent.AvvoProAdded', store)
  end
end
