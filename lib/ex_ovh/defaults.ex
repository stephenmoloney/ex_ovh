defmodule ExOvh.Defaults do
  @moduledoc :false


  def ovh() do
    [
     endpoint: endpoints()["ovh-eu"],
     api_version: "1.0"
    ]
  end


  def cloudstorage() do
    [
     keystone_endpoint: "https://auth.cloud.ovh.net/v2.0", # default endpoint for keystone (identity) auth
     region: "SBG1"
    ]
  end


  def endpoints() do
    %{
      "ovh-eu"        => "https://eu.api.ovh.com/",
      "ovh-ca"        => "https://ca.api.ovh.com/",
      "kimsufi-eu"    => "https://eu.api.kimsufi.com/",
      "kimsufi-ca"    => "https://ca.api.kimsufi.com/",
      "soyoustart-eu" => "https://eu.api.soyoustart.com/",
      "soyoustart-ca" => "https://ca.api.soyoustart.com/",
      "runabove-ca"   => "https://api.runabove.com/"
    }
  end


  def create_app_uri_suffix(), do: "createApp/"


  def consumer_key_suffix(), do: "/auth/credential"


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

