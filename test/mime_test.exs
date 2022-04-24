defmodule MIMETest do
  use ExUnit.Case, async: true

  import MIME
  doctest MIME

  test "extensions/1" do
    assert extensions("application/json; charset=utf-8") == ["json"]
    assert extensions("application/json") == ["json"]
    assert extensions("application/vnd.api+json") == ["json-api"]

    assert extensions("image/png") == ["png"]
    assert extensions("IMAGE/PNG") == ["png"]

    assert extensions("text/html") == ["html", "htm"]
    assert extensions("text/xml") == ["xml"]

    assert extensions("image/vnd.adobe.photoshop") == ["psd"]

    assert extensions("application/xml") == ["xml"]
    assert extensions("application/vnd.custom+xml") == ["xml"]
    assert extensions("application/vnd.custom+xml+xml") == []
  end

  test "type/1" do
    assert type("json") == "application/json"
    assert type("foo") == "application/octet-stream"
  end

  test "has_type?/1" do
    assert has_type?("json") == true
    assert has_type?("foo") == false
  end

  test "from_path/1" do
    assert from_path("index.html") == "text/html"
    assert from_path("index.HTML") == "text/html"
    assert from_path("inexistent.filetype") == "application/octet-stream"
    assert from_path("without-extension") == "application/octet-stream"

    assert from_path("image.psd") == "image/vnd.adobe.photoshop"
  end

  test "types map is sorted" do
    quoted = Code.string_to_quoted!(File.read!("lib/mime.ex"))

    assert {_, true} =
             Macro.postwalk(quoted, false, fn
               {:=, _, [{:types, _, _}, {:%{}, _, keys}]} = expr, _ ->
                 assert keys == Enum.sort(keys)
                 {expr, true}

               expr, val ->
                 {expr, val}
             end)
  end
end
