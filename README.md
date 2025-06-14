# JaroWinkler

JaroWinkler is a module for calculating Jaro-Winkler distance of two strings.

## Examples

```elixir
iex> JaroWinkler.exec("martha", "marhta")
0.9611111111111111

iex> JaroWinkler.exec("", "words")
0.0

iex> JaroWinkler.exec("same", "same")
1.0
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jaro_winkler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jaro_winkler, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/jaro_winkler>.

