defmodule Avrolixr.Store do
  require Logger
  def start_link, do: Agent.start_link(fn -> :avro_schema_store.new end, name: __MODULE__)

  def import_schema(schema_json) do
    Agent.get_and_update(__MODULE__, fn store ->
      try do
        updated_store = :avro_schema_store.import_schema_json(schema_json, store)
        {updated_store, updated_store}
      rescue
        e in ErlangError ->
          case e do
            %{original: {:type_with_same_name_already_exists_in_store, _}} -> nil
            other -> Logger.warn "Attempt to add schema to store failed: #{inspect(other)}"
          end
          {store, store}
      end
    end)
  end
end
