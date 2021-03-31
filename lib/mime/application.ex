defmodule MIME.Application do
  @moduledoc false

  use Application
  require Logger

  # TODO: Use Application.compile_env! instead when we require Elixir v1.10+.
  def start(_, _) do
    app = Application.fetch_env!(:mime, :types)

    if app != MIME.compiled_custom_types() do
      Logger.error("""
      The :mime library has been compiled with the following custom types:

          #{inspect(MIME.compiled_custom_types())}

      But it is being started with the following types:

          #{inspect(app)}

      We are going to dynamically recompile it during boot,
      but please clean the :mime dependency to make sure it is recompiled:

          $ mix deps.clean mime --build
      """)

      Module.create(MIME, quoted(app), file: __ENV__.file, line: __ENV__.line)
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def quoted(custom_types) do
    quote bind_quoted: [custom_types: Macro.escape(custom_types)] do
      @moduledoc """
      Maps MIME types to its file extensions and vice versa.

      MIME types can be extended in your application configuration
      as follows:

          config :mime, :types, %{
            "application/vnd.api+json" => ["json-api"]
          }

      After adding the configuration, MIME needs to be recompiled.
      If you are using mix, it can be done with:

          $ mix deps.clean mime --build

      """

      mime_file = Application.app_dir(:mime, "priv/mime.types")
      @compile :no_native
      @external_resource mime_file
      stream = File.stream!(mime_file)

      mapping =
        for line <- stream,
            not String.starts_with?(line, ["#", "\n"]),
            [type | exts] = line |> String.trim() |> String.downcase() |> String.split(),
            exts != [],
            do: {type, exts}

      @doc """
      Returns the custom types compiled into the MIME module.
      """
      def compiled_custom_types do
        unquote(Macro.escape(custom_types))
      end

      @doc false
      @deprecated "Use MIME.extensions(type) != [] instead"
      @spec valid?(String.t()) :: boolean
      def valid?(type) do
        is_list(mime_to_ext(type))
      end

      @doc """
      Returns the extensions associated with a given MIME type.

      ## Examples

          iex> MIME.extensions("text/html")
          ["html", "htm"]

          iex> MIME.extensions("application/json")
          ["json"]

          iex> MIME.extensions("application/vnd.custom+xml")
          ["xml"]

          iex> MIME.extensions("foo/bar")
          []

      """
      @spec extensions(String.t()) :: [String.t()]
      def extensions(type) do
        mime =
          type
          |> strip_params()
          |> downcase("")

        mime_to_ext(mime) || suffix(mime) || []
      end

      defp suffix(type) do
        case String.split(type, "+") do
          [type_subtype_without_suffix, suffix] -> [suffix]
          _ -> nil
        end
      end

      @default_type "application/octet-stream"

      @doc """
      Returns the MIME type associated with a file extension.

      If no MIME type is known for `file_extension`,
      `#{inspect(@default_type)}` is returned.

      ## Examples

          iex> MIME.type("txt")
          "text/plain"

          iex> MIME.type("foobarbaz")
          #{inspect(@default_type)}

      """
      @spec type(String.t()) :: String.t()
      def type(file_extension) do
        ext_to_mime(file_extension) || @default_type
      end

      @doc """
      Returns whether an extension has a MIME type registered.

      ## Examples

          iex> MIME.has_type?("txt")
          true

          iex> MIME.has_type?("foobarbaz")
          false

      """
      @spec has_type?(String.t()) :: boolean
      def has_type?(file_extension) do
        is_binary(ext_to_mime(file_extension))
      end

      @doc """
      Guesses the MIME type based on the path's extension. See `type/1`.

      ## Examples

          iex> MIME.from_path("index.html")
          "text/html"

      """
      @spec from_path(Path.t()) :: String.t()
      def from_path(path) do
        case Path.extname(path) do
          "." <> ext -> type(downcase(ext, ""))
          _ -> @default_type
        end
      end

      defp strip_params(string) do
        string |> :binary.split(";") |> hd()
      end

      defp downcase(<<h, t::binary>>, acc) when h in ?A..?Z,
        do: downcase(t, <<acc::binary, h + 32>>)

      defp downcase(<<h, t::binary>>, acc), do: downcase(t, <<acc::binary, h>>)
      defp downcase(<<>>, acc), do: acc

      @spec ext_to_mime(String.t()) :: String.t() | nil
      defp ext_to_mime(type)

      # The ones from the app always come first.
      for {type, exts} <- custom_types,
          ext <- List.wrap(exts) do
        defp ext_to_mime(unquote(ext)), do: unquote(type)
      end

      for {type, exts} <- mapping,
          ext <- exts do
        defp ext_to_mime(unquote(ext)), do: unquote(type)
      end

      defp ext_to_mime(_ext), do: nil

      @spec mime_to_ext(String.t()) :: list(String.t()) | nil
      defp mime_to_ext(type)

      for {type, exts} <- custom_types do
        defp mime_to_ext(unquote(type)), do: unquote(List.wrap(exts))
      end

      for {type, exts} <- mapping do
        defp mime_to_ext(unquote(type)), do: unquote(exts)
      end

      defp mime_to_ext(_type), do: nil
    end
  end
end
