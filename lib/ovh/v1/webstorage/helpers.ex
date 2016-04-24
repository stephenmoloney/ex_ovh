defmodule ExOvh.Ovh.V1.Webstorage.Helpers do
  @moduledoc :false
  # alias ExOvh.Ovh.V1.Webstorage.Query
  # alias Openstex.Response

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @client Keyword.fetch!(opts, :client)

      # No helpers yet

    end
  end


end
