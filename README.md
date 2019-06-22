# Brine
Brine is a configuration loader that addresses common problems with configuring Elixir applications so that they are consistent with 12 Factor.

#### Goals
1. Allow loading of configuration from a variety of sources (eg Environment, File, Etcd)
2. Avoid config per environment pattern
3. Support loading of Elixir terms
4. Be compatible with libraries not using Brine
5. Support autocomplete and compile time checks when retrieving configuration variables
6. Reduce temptation to hardcode variables by lowering friction of adding configuration

## Usage
The package can be installed by adding `brine` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:brine, "~> 0.1.0"}
  ]
end
```

Create a module to represent all configuration variables with default values
```elixir
defmodule MyApp.Config do
  use Brine
  
  def config(:myapp, [
    foo: "bar",
    nested: %{
      test: nil
    }
  ])
end
```

When your application starts load the configuration via a `Brine.Loader`. Example below uses the Environment Variable Loader. Then you can access the variables by calling the generated function.
```elixir
MYAPP_NESTED_TEST='Hello' iex -S mix
iex(1)> :ok = MyApp.Config.load(Brine.Loader.Env)
iex(2)> MyApp.Config.myapp_nested_test()
"Hello"
```

This also works with external libraries.
```elixir
defmodule MyApp.Config do
  use Brine
  
  def config(:ex_twilio, [
    account_sid: nil,
    auth_token: nil
  ])
end

EX_TWILIO_ACCOUNT_SID=xxxx EX_TWILIO_AUTH_TOKEN=xxxx iex -S mix
```

## Loading Elixir Terms
Brine supports loading Elixir terms so the following is possible
```elixir
MYAPP_FOO='{:example, 5}' iex -S mix
iex(1)> MyApp.Config.myapp_foo()
{:example, 5}
```
If the input cannot be parsed, it will assume the input is meant to be a `String`. However, Elixir by default interprets a term starting with an uppercase letter as a Module. Sometimes this isn't desired but you can coerce it into a string by wrapping it in quotes as shown below
```elixir
MYAPP_FOO='Hello' iex -S mix
iex(1)> MyApp.Config.myapp_foo()
Hello

MYAPP_FOO='"Hello"' iex -S mix
iex(1)> MyApp.Config.myapp_foo()
"Hello"
```
Still thinking about a better way to implement this so please open an issue if you have any ideas

