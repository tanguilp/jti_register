# JTIRegister

A JTI token identifier register, to prevent replay attacks

The library is composed of:
- the `JTIRegister` behaviour
- `JTIRegister.ETS`, an implementation of the abovementionned behaviour with ETS

## Installation

```elixir
def deps do
  [
    {:jti_register, "~> 0.1.0"}
  ]
end
```
