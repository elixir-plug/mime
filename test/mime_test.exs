defmodule MIMETest do
  use ExUnit.Case, async: true

  import MIME
  doctest MIME

  test "valid?/1" do
    assert valid?("application/json")
    refute valid?("application/prs.vacation-photos")
  end

  test "extensions/1" do
    assert "json" in extensions("application/json")
    assert extensions("application/vnd.api+json") == ["json-api"]
  end

  test "type/1" do
    assert type("json") == "application/json"
    assert type("foo") == "application/octet-stream"
  end

  test "from_path/1" do
    assert from_path("index.html") == "text/html"
    assert from_path("index.HTML") == "text/html"
    assert from_path("inexistent.filetype") == "application/octet-stream"
    assert from_path("without-extension") == "application/octet-stream"
  end

  test "config" do
    assert extensions("video/mp2t") == ["ts"]
    assert from_path("video.ts") == "video/mp2t"
  end
end
