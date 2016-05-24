defmodule ExOvh.Response do
  @moduledoc false
  defstruct [:body, :headers, :status_code]
  @type t :: %__MODULE__{body: any, headers: list, status_code: integer}
end