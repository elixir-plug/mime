# MIME

A library for that maps mime types to extensions and vice-versa.

## Installation

Add `mime` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:mime, "~> 1.0.0"}]
end
```

## Usage

Add any custom types you want in your `config/config.exs`:

```elixir
config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}
```

## License

MIME source code is released under Apache 2 License.

Check LICENSE file for more information.
