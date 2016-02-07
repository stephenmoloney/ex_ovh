defmodule ExOvh.Hubic.Openstack.Request do
  alias ExOvh.Hubic.Openstack.Cache

  ###################
  # Public
  ###################


  @doc "For requests to the hubic openstack compliant api"
  @spec request(method :: atom, path :: String.t, body :: String.t) :: map
  def request(method, path, body \\ :nil) do
    headers = ["X-Auth-Token": Cache.get_credentials_token()]
    if method === :get do
      headers = :lists.append(headers, ["Content-Type": "application/json"])
    end
    req_options = [ headers: headers, timeout: 10000 ]
    fullpath =  Cache.get_endpoint() <> path
    if body !== :nil do
      resp = HTTPotion.request(method, fullpath, :lists.append(req_options, [body: body]))
    else
      resp = HTTPotion.request(method, fullpath, req_options)
    end
    if Map.has_key?(resp, :body) and not resp.body in [:nil, ""]  do
      Poison.decode!(resp.body)
    else
      if resp.body in [:nil, ""] do
        body
      else
        resp
      end
    end
  end



  ###################
  # Private
  ###################

  #defp region(), do: "hubic"
  #defp access(), do: "public"


end