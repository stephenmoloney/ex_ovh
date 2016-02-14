defmodule ExOvh.Hubic.Defaults do
  @moduledoc :false

  @doc "Returns hubic default configuration settings"
  @spec hubic() :: map
  def hubic() do
    %{
      auth_uri:    "https://api.hubic.com/oauth/auth",
      token_uri:   "https://api.hubic.com/oauth/token",
      api_uri:     "https://api.hubic.com",
      api_version: "1.0"
    }
  end


end



