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

```elixir
def deps do
  [
    {:jaro_winkler, "~> 0.1.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/jaro_winkler>.

