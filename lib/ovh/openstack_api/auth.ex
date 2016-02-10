defmodule ExOvh.Ovh.Openstack.Auth do
  alias LoggingUtils
  alias ExOvh.Ovh.Defaults
  alias ExOvh.Ovh.OvhApi.Cache

  @default_headers %{ "Content-Type": "application/json; charset=utf-8" }
  @methods [:get, :post, :put, :delete]
  @timeout 10_000


  ############################
  # Public
  ############################


  @spec prepare_request(query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prepare_request({method, uri, params} = query), do: prepare_request(ExOvh, query)

  @spec prepare_request(client :: atom, query :: ExOvh.Client.raw_query_t)
                     :: ExOvh.Client.query_t
  def prepare_request(client, query)

  def prepare_request(client, {method, uri, params} = query) when method in [:get, :delete] do
    uri = uri(config, uri)
    config = config(client)
    if params !== :nil and params !== "", do: uri = uri <> URI.encode_query(params)
    consumer_key = get_consumer_key(config)
    opts = [app_secret(config), app_key(config), consumer_key, Atom.to_string(method), uri, ""]
    options = %{ headers: headers(opts, client), timeout: @timeout }
    {method, uri, options}
  end

  def prepare_request(client, {method, uri, params} = query) when method in [:post, :put] do
    uri = uri(config, uri)
    config = config(client)
    consumer_key = get_consumer_key(config)
    if params !== "" and params !== :nil and method in [:post, :put], do: params = Poison.encode!(params)
    opts = [app_secret(config), consumer_key, Atom.to_string(method), uri, params]
    options = %{ body: params, headers: headers(opts, client), timeout: @timeout }
    {method, uri, options}
  end



  ############################
  # Private
  ############################


  defp headers([app_secret, app_key, consumer_key, method, uri, body] = opts, client) do
    time = :os.system_time(:seconds) + Cache.get_time_diff(client)
    Map.merge(@default_headers,
    %{
    "X-Ovh-Application": app_key,
    "X-Ovh-Consumer":    consumer_key,
    "X-Ovh-Timestamp":   time,
    "X-Ovh-Signature":   sign_request([app_secret, consumer_key, String.upcase(method), uri, body, time])
    })
  end


  defp sign_request([app_secret, consumer_key, method, uri, body, time] = opts) do
    pre_hash = Enum.join(opts, "+") |> LoggingUtils.log_return(:debug)
    post_hash = :crypto.hash(:sha, pre_hash) |> Base.encode16(case: :lower)
    "$1$" <> post_hash
  end


  defp config(), do: Cache.get_config(ExOvh)
  defp config(client), do: Cache.get_config(client)
  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp api_version(config), do: config[:api_version]
  defp uri(config, uri), do: endpoint(config) <> api_version(config) <> uri
  defp app_secret(config), do: config[:application_secret]
  defp app_key(config), do: config[:application_key]
  defp get_consumer_key(config), do: config[:consumer_key]


end
