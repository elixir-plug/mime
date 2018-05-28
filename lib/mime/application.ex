defmodule MIME.Application do
  use Application

  def start(_, _) do
    if Application.get_env(:mime, :types, %{}) != MIME.compiled_custom_types() do
      raise """
      error while booting the mime library!

      The :mime library has been compiled with the following custom types:

          #{inspect MIME.compiled_custom_types()}

      But it is being started with the following types:

          #{inspect Application.get_env(:mime, :types, %{})}

      Please make sure the :mime dependency is recompiled:

          $ mix deps.clean mime --build
      """
    end

    Supervisor.start_link([], strategy: :one_for_one)
  end
end