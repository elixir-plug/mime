defmodule MIMETest do
  use ExUnit.Case, async: true

  import MIME
  doctest MIME

  test "valid?/1" do
    assert valid?("application/json")
    refute valid?("application/prs.vacation-photos")

    refute valid?("application/JSON")
    refute valid?("application/json; charset=utf-8")
  end

  test "extensions/1" do
    assert extensions("application/json") == ["json"]
    assert extensions("application/vnd.api+json") == ["json-api"]
    assert extensions("audio/amr") == ["amr"]
    assert extensions("IMAGE/PNG") == ["png"]

    assert extensions("application/json; charset=utf-8") == ["json"]
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
  end

  @tag :capture_log
  test "config and application recompile" do
    Application.put_env(:mime, :types, %{"video/mp2t" => ["ts"]}, persistent: true)

    assert ExUnit.CaptureIO.capture_io(:stderr, fn ->
             Application.start(:mime)
           end) =~ "redefining module MIME"

    assert extensions("video/mp2t") == ["ts"]
    assert from_path("video.ts") == "video/mp2t"
  end
end
