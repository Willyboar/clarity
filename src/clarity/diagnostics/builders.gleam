import clarity/diagnostics/types as types
import gleam/option.{type Option}
import clarity/diagnostics/location.{type Span}

/// Core constructor for a diagnostic. Most callers should use the severity
/// specific helpers below.
pub fn new(
  severity: types.Severity,
  category: types.Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> types.Diagnostic {
  types.Diagnostic(
    severity: severity,
    category: category,
    code: code,
    message: message,
    file: file,
    source: source,
    primary: types.Label(span: span, message: label_message),
    secondary: [],
    hints: [],
  )
}

/// Convenience helper for error-severity diagnostics.
pub fn error(
  category: types.Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> types.Diagnostic {
  new(types.Error, category, code, message, file, source, span, label_message)
}

/// Convenience helper for warning-severity diagnostics.
pub fn warning(
  category: types.Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> types.Diagnostic {
  new(types.Warning, category, code, message, file, source, span, label_message)
}

/// Convenience helper for informational diagnostics.
pub fn info(
  category: types.Category,
  code: Int,
  message: String,
  file: String,
  source: String,
  span: Span,
  label_message: Option(String),
) -> types.Diagnostic {
  new(types.Info, category, code, message, file, source, span, label_message)
}

/// Append a hint line that will be rendered below the message.
pub fn add_hint(diagnostic: types.Diagnostic, hint: String) -> types.Diagnostic {
  types.Diagnostic(..diagnostic, hints: [hint, ..diagnostic.hints])
}

/// Append an extra label marking a secondary span.
pub fn add_secondary_label(
  diagnostic: types.Diagnostic,
  span: Span,
  message: Option(String),
) -> types.Diagnostic {
  let label = types.Label(span: span, message: message)
  types.Diagnostic(..diagnostic, secondary: [label, ..diagnostic.secondary])
}

/// Replace the primary label span and optional message.
pub fn with_primary_label(
  diagnostic: types.Diagnostic,
  span: Span,
  message: Option(String),
) -> types.Diagnostic {
  types.Diagnostic(
    ..diagnostic,
    primary: types.Label(span: span, message: message),
  )
}
