defmodule MimeTest do
  use ExUnit.Case
  use Mime

  doctest Mime

  test "valid mime type" do
    assert Mime.valid?("application/json")
  end

  test "one or more extensions" do
    assert "json" in Mime.extensions("application/json")
  end

  test "ext to type" do
    assert "application/json" == Mime.type("json")
  end

  test "default ext to type" do
    assert "application/octet-stream" == Mime.type("default")
  end

  # added just as reminder tests will fail if we don't bump the number
  test "correct version number" do
    assert "0.0.1" = Mime.version
  end

end
