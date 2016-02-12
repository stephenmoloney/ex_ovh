defmodule ExOvh.Ovh.OvhApi.Request do
  alias ExOvh.Ovh.OvhApi.Auth
  alias ExOvh.Ovh.OvhApi.Cache
  alias ExOvh.Ovh.Defaults

  ############################
  # Public
  ############################


  @spec request(client :: atom, query :: ExOvh.Client.query_t)
               :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    LoggingUtils.log_mod_func_line(__ENV__, :debug)
    config = config(client)

    {method, uri, options} = Auth.prepare_request(client, query)
    |> LoggingUtils.log_return(:debug)

    resp = HTTPotion.request(method, uri, options)
    if resp.status_code >= 100 and resp.status_code < 300 do
      {:ok, %{
             body: resp.body |> Poison.decode!(),
             headers: resp.headers,
             status_code: resp.status_code
            }
      }
    else
     {:error, resp}
    end
  end


  ############################
  # Private
  ############################


  defp config(), do: Cache.get_config(ExOvh)
  defp config(client), do: Cache.get_config(client)
  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp api_version(config), do: config[:api_version]


end

