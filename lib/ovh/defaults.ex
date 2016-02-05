defmodule ExOvh.Ovh.Defaults do

  @doc "Returns ovh default configuration settings"
  @spec ovh() :: map
  def ovh() do
    %{
      endpoint: "ovh-eu",
      api_version: "1.0"
    }
  end


  @doc "Returns map of ovh endpoints"
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


  @doc "Returns the default access rules (all methods and paths)"
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

