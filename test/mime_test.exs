defmodule MIMETest do
  use ExUnit.Case, async: true

  import MIME
  doctest MIME

  defp recompile! do
    [File.cwd!(), "lib", "mime.ex"]
    |> Path.join()
    |> Code.compile_file()
  end

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
    assert extensions("application/vnd.custom+inexist") == []
    assert extensions("application/vnd.custom+xml/extrainvalid") == []
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

  test "known_types/0" do
    Application.put_env(:mime, :types, %{"application/dicom" => ["dcm"]})
    recompile!()

    assert is_map(known_types())

    assert Map.has_key?(known_types(), "application/json")
    assert Map.has_key?(known_types(), "application/dicom")

    assert Map.get(known_types(), "application/json") == ["json"]
    assert Map.get(known_types(), "application/dicom") == ["dcm"]
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

  test "overrides types" do
    Application.put_env(:mime, :types, %{"text/plain" => ["env"]})
    recompile!()

    assert MIME.extensions("text/plain") == ["env"]
    assert MIME.type("env") == "text/plain"
    assert MIME.type("txt") == "application/octet-stream"
    assert MIME.type("text") == "application/octet-stream"
  end

  test "overrides extensions" do
    Application.put_env(:mime, :types, %{"audio/x-wav" => ["wav"]})

    assert_raise RuntimeError,
                 ~r"You must tell us which mime-type is preferred by defining the :extensions configuration",
                 fn -> recompile!() end

    Application.put_env(:mime, :extensions, %{"wav" => "audio/x-wav"})
    recompile!()

    assert MIME.extensions("audio/wav") == ["wav"]
    assert MIME.extensions("audio/x-wav") == ["wav"]
    assert MIME.type("wav") == "audio/x-wav"
  end

  test "overrides suffixes" do
    Application.put_env(:mime, :suffixes, %{"custom-format" => ["cf"]})
    recompile!()

    assert MIME.extensions("text/plain+custom-format") == ["cf"]
  end
end
