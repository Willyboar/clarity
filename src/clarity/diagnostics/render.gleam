import clarity/diagnostics/location
import clarity/diagnostics/style
import clarity/diagnostics/types as types
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

/// Render a diagnostic into a multi-line string using the provided style.
pub fn render(diagnostic: types.Diagnostic, palette: style.Style) -> String {
  let header = render_header(diagnostic, palette)
  let lines = render_location(diagnostic, palette)
  let hints = render_hints(diagnostic, palette)

  let output = case hints {
    [] -> list.flatten([[header], lines])
    _ -> list.flatten([[header], lines, [""], hints])
  }

  string.join(output, "\n")
}

/// Build the decorated header line containing severity, code, and message.
fn render_header(diagnostic: types.Diagnostic, palette: style.Style) -> String {
  let severity = styled_severity(diagnostic.severity, palette)
  let code_text = types.format_code(diagnostic.category, diagnostic.code)
  let code = style.code_for(palette, diagnostic.severity, code_text)
  let bracket_open = style.code_for(palette, diagnostic.severity, "[")
  let bracket_close = style.code_for(palette, diagnostic.severity, "]")
  severity
  <> bracket_open
  <> code
  <> bracket_close
  <> ": "
  <> style.bold(diagnostic.message)
}

/// Apply the correct severity-specific formatter.
fn styled_severity(severity: types.Severity, palette: style.Style) -> String {
  case severity {
    types.Error -> palette.severity_error(types.severity_name(severity))
    types.Warning -> palette.severity_warning(types.severity_name(severity))
    types.Info -> palette.severity_info(types.severity_name(severity))
  }
}

/// Render the file path and annotated source line.
fn render_location(
  diagnostic: types.Diagnostic,
  palette: style.Style,
) -> List(String) {
  let types.Diagnostic(file: file, source: source, primary: label, ..) =
    diagnostic
  let severity = diagnostic.severity
  let types.Label(span: span, message: _) = label
  let location.Span(start: start, end: _) = span

  let location.Position(line: line_number, column: column) = start
  let relative_path = shorten_path(file)
  let path_text =
    relative_path
    <> ":"
    <> int.to_string(line_number)
    <> ":"
    <> int.to_string(column)
  let header = "  " <> palette.secondary("┌─") <> " " <> palette.path(path_text)
  let divider = "  " <> palette.secondary("│")

  let digits = digit_count(line_number)
  let padded_line = pad_line_number(line_number, digits, palette)
  let line_content = fetch_line(source, line_number)
  let line_line =
    padded_line <> " " <> palette.secondary("│") <> " " <> line_content

  let pointer_line = render_pointer_line(severity, label, digits, palette)
  let secondary_lines =
    render_secondary_labels(
      diagnostic.secondary,
      severity,
      digits,
      source,
      palette,
    )

  list.flatten([[header, divider, line_line, pointer_line], secondary_lines])
}

/// Render the pointer carets and optional inline message.
fn render_pointer_line(
  severity: types.Severity,
  label: types.Label,
  digits: Int,
  palette: style.Style,
) -> String {
  let types.Label(span: span, message: message) = label
  let location.Span(start: start, end: end_) = span
  let location.Position(column: start_column, ..) = start
  let location.Position(column: end_column, ..) = end_
  let offset = int.max(start_column - 1, 0)
  let raw_width = int.max(end_column - start_column, 0)
  let width = case raw_width {
    0 -> 1
    _ -> raw_width
  }
  let pointer_padding = string.repeat(" ", offset)
  let pointer_marks =
    style.pointer_for(palette, severity, string.repeat("^", width))
  let pointer_message = case message {
    Some(text) -> " " <> style.pointer_for(palette, severity, text)
    None -> ""
  }

  string.repeat(" ", digits)
  <> " "
  <> palette.secondary("│")
  <> " "
  <> pointer_padding
  <> pointer_marks
  <> pointer_message
}

fn render_secondary_labels(
  labels: List(types.Label),
  severity: types.Severity,
  primary_digits: Int,
  source: String,
  palette: style.Style,
) -> List(String) {
  labels
  |> list.reverse
  |> list.flat_map(fn(label) {
    render_secondary_label(label, severity, primary_digits, source, palette)
  })
}

fn render_secondary_label(
  label: types.Label,
  severity: types.Severity,
  primary_digits: Int,
  source: String,
  palette: style.Style,
) -> List(String) {
  let types.Label(span: span, message: message) = label
  let location.Span(start: start, end: _end) = span
  let location.Position(line: line, column: _column) = start
  let digits = int.max(primary_digits, digit_count(line))
  let padded_line = pad_line_number(line, digits, palette)
  let line_content = fetch_line(source, line)
  let pointer_line = render_pointer_line(severity, label, digits, palette)
  let info_line =
    "  "
    <> palette.secondary("│")
    <> "  "
    <> palette.secondary(format_span_range(span))
    <> case message {
      Some(text) -> " " <> palette.secondary("- " <> text)
      None -> ""
    }

  [
    padded_line <> " " <> palette.secondary("│") <> " " <> line_content,
    pointer_line,
    info_line,
  ]
}

fn format_span_range(span: location.Span) -> String {
  let location.Span(start: start, end: end_) = span
  let location.Position(line: start_line, column: start_column) = start
  let location.Position(line: end_line, column: end_column) = end_
  case start_line == end_line {
    True ->
      case start_column == end_column {
        True ->
          "line "
          <> int.to_string(start_line)
          <> ", column "
          <> int.to_string(start_column)
        False ->
          "line "
          <> int.to_string(start_line)
          <> ", columns "
          <> int.to_string(start_column)
          <> "–"
          <> int.to_string(end_column)
      }

    False ->
      "lines "
      <> int.to_string(start_line)
      <> ":"
      <> int.to_string(start_column)
      <> "–"
      <> int.to_string(end_line)
      <> ":"
      <> int.to_string(end_column)
  }
}

/// Render any accumulated hint lines.
fn render_hints(
  diagnostic: types.Diagnostic,
  palette: style.Style,
) -> List(String) {
  diagnostic.hints
  |> list.reverse
  |> list.map(fn(hint) { palette.hint("Hint:") <> " " <> hint })
}

/// Align line numbers to the width of the highest line.
fn pad_line_number(number: Int, width: Int, palette: style.Style) -> String {
  let text = int.to_string(number)
  let padding = width - string.length(text)
  let prefix = case padding {
    p if p > 0 -> string.repeat(" ", p)
    _ -> ""
  }
  palette.line_number(prefix <> text)
}

/// Count digits in a (non-negative) line number for padding.
fn digit_count(number: Int) -> Int {
  let value = case number {
    n if n <= 0 -> 1
    n -> n
  }
  string.length(int.to_string(value))
}

/// Fetch the specified 1-indexed line from the source text.
fn fetch_line(source: String, number: Int) -> String {
  let lines = string.split(source, "\n")
  take_line(lines, number)
  |> string.replace("\r", "")
}

/// Helper that walks the list of lines to the requested index.
fn take_line(lines: List(String), number: Int) -> String {
  case number, lines {
    n, _ if n <= 1 ->
      case lines {
        [line, ..] -> line
        [] -> ""
      }

    n, [_ignored, ..rest] -> take_line(rest, n - 1)
    _, [] -> ""
  }
}

/// Trim an absolute path down to its `src/...` suffix when possible.
fn shorten_path(path: String) -> String {
  let parts = string.split(path, "/src/")
  case parts {
    [left, right] ->
      case string.contains(left, "/") {
        True -> "src/" <> right
        False -> path
      }

    _ -> path
  }
}
