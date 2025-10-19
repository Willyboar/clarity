import gleam/int
import gleam/option.{type Option}
import gleam/string
import clarity/diagnostics/location.{type Span}

/// Severity level assigned to a diagnostic.
pub type Severity {
  Error
  Warning
  Info
}

/// Diagnostic categories covering the main compiler phases.
pub type Category {
  Lexing
  Parsing
  Syntax
  Typing
  Semantic
  Compilation
  Runtime
  General
}

/// Additional annotation attached to a span.
pub type Label {
  Label(span: Span, message: Option(String))
}

/// Diagnostic payload containing metadata, labels, and opt-in hints.
pub type Diagnostic {
  Diagnostic(
    severity: Severity,
    category: Category,
    code: Int,
    message: String,
    file: String,
    source: String,
    primary: Label,
    secondary: List(Label),
    hints: List(String),
  )
}

/// Human readable severity name for header rendering.
pub fn severity_name(severity: Severity) -> String {
  case severity {
    Error -> "Error"
    Warning -> "Warning"
    Info -> "Info"
  }
}

/// Textual name for categories.
pub fn category_name(category: Category) -> String {
  case category {
    Lexing -> "Lexing"
    Parsing -> "Parsing"
    Syntax -> "Syntax"
    Typing -> "Typing"
    Semantic -> "Semantic"
    Compilation -> "Compilation"
    Runtime -> "Runtime"
    General -> "General"
  }
}

/// Letter prefix used when formatting a diagnostic code.
pub fn category_letter(category: Category) -> String {
  case category {
    Lexing -> "L"
    Parsing -> "P"
    Syntax -> "X"
    Typing -> "T"
    Semantic -> "S"
    Compilation -> "C"
    Runtime -> "R"
    General -> "G"
  }
}

/// Format a category and numeric identifier into `X000`.
pub fn format_code(category: Category, number: Int) -> String {
  let letter = category_letter(category)
  letter <> zero_pad(int.absolute_value(number), 3)
}

/// Left-pad a number with zeros to the desired width.
fn zero_pad(number: Int, width: Int) -> String {
  let text = int.to_string(number)
  let padding = width - string.length(text)
  case padding > 0 {
    True -> string.repeat("0", padding) <> text
    False -> text
  }
}
