defmodule Mime do

  @default "application/octet-stream"

  @doc false
  def __using__(_opts) do
    quote do
      import Mime
    end
  end

  stream = File.stream! Path.expand("../priv/mime.types", __DIR__)
  mapping = stream 
    |> Enum.reduce([], fn(line, acc) ->
      if String.match?(line, ~r/^[#\n]/) do
        acc
      else
        [type | exts] = line |> String.strip |> String.split
        [{type, exts} | acc]
      end
    end)
    |> Enum.reverse 

  def valid?(t) do
    is_list entry(t)
  end

  def extensions(t) do
    entry(t) || []
  end

  for {type, exts} <- mapping do
    for ext <- exts do
      def type(unquote(ext)), do: unquote(type)
    end
  end

  def type(_), do: @default

  for {type, exts} <- mapping do
    defp entry(unquote(type)), do: unquote(exts)
  end

  defp entry(_), do: nil

  def version do
    Mix.Project.config[:version]
  end
end