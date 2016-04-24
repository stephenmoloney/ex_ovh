defmodule ExOvh.Ovh.Query do
  @moduledoc false
  defstruct [:method, :uri, :params,  service: :ovh]
  @type t :: %__MODULE__{method: atom, uri: String.t, params: any, service: :ovh}
end