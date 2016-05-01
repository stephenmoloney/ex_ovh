defmodule ExOvh.Defaults do
  @moduledoc :false

  @doc "Returns ovh default configuration settings"
  @spec ovh() :: map
  def ovh() do
    %{
      endpoint: "ovh-eu",
      api_version: "1.0",
      cloudstorage_endpoint: "https://auth.cloud.ovh.net/v2.0"
    }
  end


  @doc "Returns a map of ovh endpoints"
  @spec endpoints() :: map
  def endpoints() do
    %{
      "ovh-eu"        => "https://api.ovh.com/",
      "ovh-ca"        => "https://ca.api.ovh.com/",
      "kimsufi-eu"    => "https://eu.api.kimsufi.com/",
      "kimsufi-ca"    => "https://ca.api.kimsufi.com/",
      "soyoustart-eu" => "https://eu.api.soyoustart.com/",
      "soyoustart-ca" => "https://ca.api.soyoustart.com/",
      "runabove-ca"   => "https://api.runabove.com/"
    }
  end

  @doc "Returns the default suffix for creating a new application in ovh"
  @spec create_app_uri_suffix() :: String.t
  def create_app_uri_suffix(), do: "createApp/"


  @doc "Returns the default suffix for getting the consumer key in ovh"
  @spec consumer_key_suffix() :: String.t
  def consumer_key_suffix(), do: "/auth/credential/"


  @doc "Returns the default access rules (all methods and paths by default)"
  @spec access_rules() :: [map]
  def access_rules() do
     [
        %{
            method: "GET",
            path: "/*"
        },
        %{
            method: "POST",
            path: "/*"
        },
        %{
            method: "PUT",
            path: "/*"
        },
        %{
            method: "DELETE",
            path: "/*"
        }
    ]
  end


end

