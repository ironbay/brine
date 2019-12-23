defmodule Brine.Loader do
  @callback get(app :: atom(), path :: Enumerable.t()) :: any()
end

defmodule Brine.Loader.Env do
  @behaviour Brine.Loader

  @spec get(any, any) :: any()
  def get(app, path) do
    [app | path]
    |> Enum.join("_")
    |> String.upcase()
    |> String.replace(":", "")
    |> String.replace(".", "_")
    |> System.get_env()
    |> case do
      nil ->
        nil

      result ->
        try do
          {result, _} = Code.eval_string(result)
          result
        rescue
          _ -> result
        end
    end
  end
end
