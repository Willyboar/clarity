/// High level diagnostic API for the Clarity language.
///
/// This module wires together the type definitions, builders, rendering logic,
/// and convenience constructors so downstream code can report rich compiler
/// diagnostics with coloured CLI output.
import clarity/diagnostics/builders
import clarity/diagnostics/location
import clarity/diagnostics/render as renderer
import clarity/diagnostics/style as styles
import clarity/diagnostics/types
import gleam/option.{type Option}

pub type Severity =
  types.Severity

pub type Category =
  types.Category

pub type Label =
  types.Label

pub type Diagnostic =
  types.Diagnostic

pub type Position =
  location.Position

pub type Span =
  location.Span

pub type Style =
  styles.Style

pub fn position(line: Int, column: Int) -> Position {
  location.position(line, column)
}

pub fn span(
  start_line: Int,
  start_column: Int,
  end_line: Int,
  end_column: Int,
) -> Span {
  location.span(start_line, start_column, end_line, end_column)
}

pub fn span_on_line(line: Int, start_column: Int, width: Int) -> Span {
  location.span_on_line(line, start_column, width)
}

pub fn merge_spans(left: Span, right: Span) -> Span {
  location.merge(left, right)
}

pub fn new(
  severity: Severity,
  category: Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> Diagnostic {
  builders.new(
    severity,
    category,
    code,
    message,
    file,
    source,
    span,
    label_message,
  )
}

pub fn error(
  category: Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> Diagnostic {
  builders.error(category, code, message, file, source, span, label_message)
}

pub fn warning(
  category: Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> Diagnostic {
  builders.warning(category, code, message, file, source, span, label_message)
}

pub fn info(
  category: Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> Diagnostic {
  builders.info(category, code, message, file, source, span, label_message)
}

pub fn add_hint(diagnostic: Diagnostic, hint: String) -> Diagnostic {
  builders.add_hint(diagnostic, hint)
}

pub fn add_secondary_label(
  diagnostic: Diagnostic,
  span: Span,
  message: Option(String),
) -> Diagnostic {
  builders.add_secondary_label(diagnostic, span, message)
}

pub fn with_primary_label(
  diagnostic: Diagnostic,
  span: Span,
  message: Option(String),
) -> Diagnostic {
  builders.with_primary_label(diagnostic, span, message)
}

pub fn render(diagnostic: Diagnostic, style: Style) -> String {
  renderer.render(diagnostic, style)
}

pub fn default_style() -> Style {
  styles.default_style()
}

pub fn monochrome_style() -> Style {
  styles.monochrome_style()
}

pub fn severity_name(severity: Severity) -> String {
  types.severity_name(severity)
}

pub fn category_letter(category: Category) -> String {
  types.category_letter(category)
}

pub fn format_code(category: Category, number: Int) -> String {
  types.format_code(category, number)
}
