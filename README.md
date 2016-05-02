# MIME

A library for that maps mime types to extensions and vice-versa.

## Installation

The package can be installed as:

1. Add mime to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:mime, "~> 1.0"}]
  end
  ```
  
## Usage

MIME types can be extended in your application configuration
as follows:

```elixir
config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}
```

## License

MIME source code is released under Apache 2 License.

Check LICENSE file for more information.
