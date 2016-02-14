defmodule ExOvh.Client do
  alias ExOvh.Defaults


  @type method_t :: atom()
  @type path_t :: String.t
  @type params_t :: map() | :nil
  @type options_t :: map() | :nil
  @type raw_query_t :: { method_t, path_t, params_t }
  @type query_t :: { method_t, path_t, options_t }
  @type response_t :: %{ body: map() | String.t, headers: map(), status_code: integer() }


  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app] || :ex_ovh


      if(@otp_app !== :ex_ovh)  do
        def config(), do: Application.get_env(@otp_app, __MODULE__) |> Enum.into(%{})
      else
        def config(), do: Application.get_all_env(@otp_app) |> Enum.into(%{})
      end


      def start_link(opts \\ []) do
        ExOvh.Supervisor.start_link(__MODULE__, config(), opts)
      end


      def ovh_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Ovh.Request.request(__MODULE__, query, opts)
      end


      def ovh_prepare_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Ovh.Auth.prepare_request(__MODULE__, query, opts)
      end


      def hubic_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Hubic.Request.request(__MODULE__, query, opts)
      end


      def hubic_prepare_request({method, uri, params} = query, opts \\ %{}) do
        ExOvh.Hubic.Auth.prepare_request(__MODULE__, query, opts)
      end


    end
  end


  @doc """
  Starts the ovh and the hubic supervisors.
  """
  @callback start_link() :: :ok | {:error, {:already_started, pid}} | {:error, term}


  @doc ~S"""
  Gets the ovh and hubic config from the application environment.

  Returns a map if the config is present in the config.exs file(s)
  or
  Returns :nil if the config is absent.
  """
  @callback config() :: :nil | map



  @doc """
  Prepares all elements necessary for making a request to the ovh api.

  Returns a tuple `{method, uri, options}` which is the `query_t` tuple.
  With the returned query_t, a request can easily be made with
  the `ovh_request` function or [HTTPotion](http://hexdocs.pm/httpotion/HTTPotion.html).

  ## Example

  Making a request to the custom ovh api:
      query = ExOvh.ovh_prepare_request({:get, "/cdn/webstorage", :nil}, %{})


  Making a request to the openstack compliant ovh cdn webstorage service:
      query = ExOvh.ovh_prepare_request({:get, "<account_name>", %{"format" => "json"}}, %{ openstack: :true, webstorage: "<ovh_service_name>" })
  """
  @callback ovh_prepare_request(query :: raw_query_t)
                             :: query_t



  @doc ~S"""
  Makes a request to the ovh api.

  Returns a `response_t` map  with the structure:
  `%{ body: <body>, headers: [<headers>], status_code: <code>}`

  ## Example

  Making a request to the custom ovh api:
      ExOvh.ovh_request({:get, "/cdn/webstorage", :nil}, %{})

  Making a request to the openstack compliant ovh cdn webstorage service:
      ExOvh.ovh_request({:get, "<account_name>", %{"format" => "json"}}, %{ openstack: :true, webstorage: "<ovh_service_name>" })
  """
  @callback ovh_request(query :: raw_query_t, opts :: map)
                        :: {:ok, response_t} | {:error, response_t}




  @doc ~S"""
  Makes a request to the hubic api.

  Returns a map `%{ body: <body>, headers: %{<headers>}, status_code: <code>}`
  """
  @callback hubic_request(query :: raw_query_t, opts :: map)
                         :: {:ok, response_t} | {:error, response_t}


  @doc ~S"""
  Prepares all elements necessary prior to making a request to the hubic api.

  Returns a tuple `{method, uri, options}`
  """
  @callback hubic_prepare_request(query :: raw_query_t)
                               :: query_t


end
