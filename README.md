# Clarity Diagnostics

Rich, colourised compiler diagnostics for the Clarity language (and friends).
The library provides a comprehensive set of error, warning, and informational
constructors spanning lexing, parsing, syntax validation, typing, semantic
analysis, compilation, and runtime phases.

The implementation ships with a CLI renderer powered by ANSI colours, helpers
for constructing and combining diagnostics, and a large catalogue of predefined
messages to plug directly into your compiler pipeline.

## Quick Start

```gleam
import clarity/diagnostics as diag

pub fn report() -> String {
  let sample_source = "let value = unknown + 1\n"
  let diagnostic =
    diag.messages.type_unknown_identifier(
      "example.clr",
      sample_source,
      diag.span_on_line(1, 13, 13),
      "unknown",
    )
    |> diag.add_hint("Did you forget to import the module exporting `unknown`?")

  diag.render(diagnostic, diag.default_style())
}
```

## Running The Showcase

A `play.gleam` module renders every predefined message with hard-coded sample
source. Execute it directly to preview the output:

```sh
gleam run
# or
gleam run -m play
```

## Modules

- `clarity/diagnostics` – core API, builders, renderer, and ANSI styles
- `clarity/diagnostics/messages` – exhaustive catalogue of ready-made diagnostics
- `clarity/diagnostics/location` – 1-indexed line/column span helpers

## Development

```sh
gleam run    # Render the showcase diagnostics
gleam test   # Run the test suite
```
