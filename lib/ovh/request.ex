defmodule ExOvh.Ovh.Request do
  alias ExOvh.Ovh.Auth
  alias LoggingUtils
  alias ExOvh.Ovh.Defaults
  alias ExOvh.Ovh.Cache

  ############################
  # Public
  ############################


  @spec request(method :: atom, uri :: String.t, params :: map, signed :: boolean) :: map
  def request(method, uri, params, signed) when signed === :true, do: request(ExOvh, method, uri, params, :true)
  def request(method, uri, params, signed) when signed === :false, do: request(ExOvh, method, uri, params, :false)


  @spec request(client :: atom, method :: atom, uri :: String.t, params :: map, signed :: boolean) :: map
  def request(client, method, uri, params, signed) do
    config = config(client)
    {method, uri, options} = Auth.prep_request(client, method, uri, params, signed)
    resp = HTTPotion.request(method, uri, options)
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers |> Enum.into(%{}),
      status_code: resp.status_code
    }
  end


  ############################
  # Private
  ############################


  defp config(), do: Cache.get_config(ExOvh)
  defp config(client), do: Cache.get_config(client)
  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp api_version(config), do: config[:api_version]


end

