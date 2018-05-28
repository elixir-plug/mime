# MIME

[![Build Status](https://travis-ci.org/elixir-plug/mime.svg?branch=master)](https://travis-ci.org/elixir-plug/mime)

A read-only and immutable MIME type module for Elixir.

This library embeds the MIME type database so we can map MIME types to extensions and vice-versa. The library was designed to be read-only for performance. New types can only be added at compile-time via configuration.

This library is used by projects like Plug and Phoenix.

See [the documentation for more information](http://hexdocs.pm/mime/).

## Installation

The package can be installed as:

1. Add mime to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:mime, "~> 1.2"}]
    end
    ```

2. If there is an `applications` key in your `mix.exs`, add `:mime` to the list. This step is not necessary if you have `extra_applications` instead.

    ```elixir
    def application do
      [applications: [:mime]]
    end
    ```

## License

MIME source code is released under Apache 2 License.

Check LICENSE file for more information.
