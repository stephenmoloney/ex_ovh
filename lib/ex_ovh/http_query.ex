defmodule ExOvh.HttpQuery do
  @moduledoc false
  defstruct [method: :nil, uri: :nil, body: "", headers: [], hackney_options: [], completed_transformations: []]
  @type t :: %__MODULE__{
                        method: atom,
                        uri: String.t,
                        body: :binary | {:file, :binary},
                        headers: [{binary, binary}],
                        hackney_options: Keyword.t,
                        completed_transformations: []
                        }
end
