defmodule ExOvh.Query do
  @moduledoc false
  defstruct [:method, :uri, :params, headers: [], service: :ovh]
  @type t :: %__MODULE__{method: atom, uri: String.t, params: any, headers: list, service: :ovh}
end

defmodule ExOvh.HttpQuery do
  @moduledoc false
  defstruct [method: :nil, uri: :nil, body: "", headers: [], options: [], service: :ovh]
  @type t :: %__MODULE__{
                        method: atom,
                        uri: String.t,
                        body: :binary | {:file, :binary},
                        headers: [{binary, binary}],
                        options: Keyword.t,
                        service: atom
                        }
end
