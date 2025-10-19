import clarity/diagnostics/types as types

const esc_code = "\u{001b}"
const reset = esc_code <> "[0m"

fn wrap(code: String, text: String) -> String {
  esc_code <> "[" <> code <> "m" <> text <> reset
}

fn wrap_effect(code: String, text: String) -> String {
  esc_code <> "[" <> code <> "m" <> text <> reset
}

/// Basic colour palette derived from the original `colours.gleam` module.
pub fn red(text: String) -> String {
  bold_colour("38;5;196", text)
}

pub fn yellow(text: String) -> String {
  bold_colour("38;5;220", text)
}

pub fn blue(text: String) -> String {
  bold_colour("38;5;39", text)
}

pub fn grey(text: String) -> String {
  bold_colour("38;5;245", text)
}

pub fn orange(text: String) -> String {
  bold_colour("38;5;208", text)
}

pub fn cyan(text: String) -> String {
  bold_colour("38;5;14", text)
}

pub fn green(text: String) -> String {
  bold_colour("38;5;2", text)
}

pub fn light_green(text: String) -> String {
  bold_colour("38;5;120", text)
}

pub fn bold(text: String) -> String {
  wrap_effect("1", text)
}

pub fn italic(text: String) -> String {
  wrap_effect("3", text)
}

pub fn underline(text: String) -> String {
  wrap_effect("4", text)
}

fn bold_colour(code: String, text: String) -> String {
  wrap("1;" <> code, text)
}

/// Functions used to colour and emphasise different diagnostic elements.
pub type Style {
  Style(
    severity_error: fn(String) -> String,
    severity_warning: fn(String) -> String,
    severity_info: fn(String) -> String,
    code_error: fn(String) -> String,
    code_warning: fn(String) -> String,
    code_info: fn(String) -> String,
    path: fn(String) -> String,
    line_number: fn(String) -> String,
    pointer_error: fn(String) -> String,
    pointer_warning: fn(String) -> String,
    pointer_info: fn(String) -> String,
    hint: fn(String) -> String,
    secondary: fn(String) -> String,
  )
}

/// Colourful style used for CLI output.
pub fn default_style() -> Style {
  Style(
    severity_error: fn(text) { red(text) },
    severity_warning: fn(text) { yellow(text) },
    severity_info: fn(text) { light_green(text) },
    code_error: fn(text) { red(text) },
    code_warning: fn(text) { yellow(text) },
    code_info: fn(text) { light_green(text) },
    path: fn(text) { italic(text) },
    line_number: fn(text) { grey(text) },
    pointer_error: fn(text) { red(text) },
    pointer_warning: fn(text) { yellow(text) },
    pointer_info: fn(text) { light_green(text) },
    hint: fn(text) { blue(text) },
    secondary: fn(text) { grey(text) },
  )
}

/// Monochrome style useful for tests or plain environments.
pub fn monochrome_style() -> Style {
  Style(
    severity_error: fn(text) { text },
    severity_warning: fn(text) { text },
    severity_info: fn(text) { text },
    code_error: fn(text) { text },
    code_warning: fn(text) { text },
    code_info: fn(text) { text },
    path: fn(text) { text },
    line_number: fn(text) { text },
    pointer_error: fn(text) { text },
    pointer_warning: fn(text) { text },
    pointer_info: fn(text) { text },
    hint: fn(text) { text },
    secondary: fn(text) { text },
  )
}

pub fn code_for(style: Style, severity: types.Severity, text: String) -> String {
  let Style(
    code_error: code_error,
    code_warning: code_warning,
    code_info: code_info,
    ..
  ) = style
  case severity {
    types.Error -> code_error(text)
    types.Warning -> code_warning(text)
    types.Info -> code_info(text)
  }
}

pub fn pointer_for(style: Style, severity: types.Severity, text: String) -> String {
  let Style(
    pointer_error: pointer_error,
    pointer_warning: pointer_warning,
    pointer_info: pointer_info,
    ..
  ) = style
  case severity {
    types.Error -> pointer_error(text)
    types.Warning -> pointer_warning(text)
    types.Info -> pointer_info(text)
  }
}
