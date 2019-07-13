defmodule Brine do
  defmacro __using__(_opts) do
    quote do
      import Brine

      Module.register_attribute(
        __MODULE__,
        :apps,
        accumulate: true,
        persist: false
      )

      @before_compile Brine
    end
  end

  defmacro config(app, fields) do
    {schema, _} = Code.eval_quoted(fields)
    flattened = Dynamic.flatten(schema)

    [
      quote do
        @apps {unquote(app), unquote(flattened)}
      end,
      quote do
        def unquote(app)() do
          Application.get_all_env(unquote(app))
        end
      end,
      flattened
      |> Stream.flat_map(fn {path, value} ->
        count = Enum.count(path)

        {result, _} =
          path
          |> Stream.with_index()
          |> Enum.reduce({[], []}, fn {item, index}, {all, last} ->
            next = last ++ [item]
            {[{next, if(index + 1 == count, do: value, else: nil)} | all], next}
          end)

        result
      end)
      |> Stream.uniq_by(fn {path, _value} -> path end)
      |> Enum.map(fn {path, _value} ->
        fun =
          [app | path]
          |> Enum.join("_")
          |> String.to_atom()

        case path do
          [root] ->
            quote do
              def unquote(fun)() do
                Application.get_env(unquote(app), unquote(root))
              end
            end

          [root | rest] ->
            quote do
              def unquote(fun)() do
                unquote(app)
                |> Application.get_env(unquote(root))
                |> Dynamic.get(unquote(rest))
              end
            end
        end
      end)
    ]
  end

  defmacro __before_compile__(_env) do
    quote do
      def load(loader) do
        Enum.each(@apps, fn {app, values} ->
          values
          |> Enum.reduce(%{}, fn {path, default}, collect ->
            Dynamic.put(collect, path, loader.get(app, path) || default)
          end)
          |> Enum.each(fn {key, value} ->
            Application.put_env(app, key, value)
          end)
        end)

        :ok
      end
    end
  end
end

defmodule Brine.Example do
  use Brine

  config(:foo,
    test: "cool",
    bar: %{
      nice: "lol"
    }
  )
end
