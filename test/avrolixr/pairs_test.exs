defmodule Avrolixr.PairsTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Avrolixr.Codec.Pairs

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

    test "list of strings" do
      list = [{'id', 2696047},
        {'updated_attributes',
          ['specialty_id', 'specialty_id_updated_by', 'specialty_id_updated_at',
            'updated_at']},
        {'event',
          [{'name', 'QuestionUpdated'}, {'timestamp', 1472501025},
            {'app_id', 'content'}]}]
      map = %{
        "id" => 2696047,
        "updated_attributes" => ["specialty_id", "specialty_id_updated_by",
          "specialty_id_updated_at", "updated_at"],
        "event" => %{
          "name" => "QuestionUpdated",
          "timestamp" => 1472501025,
          "app_id" => "content",
        }
      }
      assert Pairs.to_map(list) == map
    end
  end
end
