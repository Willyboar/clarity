import gleam/int
import gleam/option.{Some}
import clarity/diagnostics/builders as build
import clarity/diagnostics/location.{type Span}
import clarity/diagnostics/types as types

/// =============================================
/// LEXING
/// =============================================
pub fn lex_unexpected_character(
  file: String,
  source: String,
  span: Span,
  character: String,
) -> types.Diagnostic {
  build.error(
    types.Lexing,
    1,
    "Unexpected character in source stream",
    file,
    source,
    span,
    Some("unexpected character"),
  )
  |> build.add_hint("Remove the character or ensure it belongs to a valid token.")
  |> build.add_hint("If this is Unicode, confirm the source file is UTF-8 encoded.")
  |> build.add_secondary_label(span, Some("Found `" <> character <> "` here"))
}

pub fn lex_unterminated_string(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.error(
    types.Lexing,
    2,
    "Unterminated string literal",
    file,
    source,
    span,
    Some("string literal continues to end of file"),
  )
  |> build.add_hint("Check that every string starts and ends with matching quotes.")
}

pub fn lex_unterminated_block_comment(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.error(
    types.Lexing,
    3,
    "Block comment reaches end of file",
    file,
    source,
    span,
    Some("comment started here"),
  )
  |> build.add_hint("Add a closing `*/` before the file terminates.")
}

pub fn lex_invalid_numeric_literal(
  file: String,
  source: String,
  span: Span,
  literal: String,
) -> types.Diagnostic {
  build.error(
    types.Lexing,
    4,
    "Invalid numeric literal",
    file,
    source,
    span,
    Some("invalid number"),
  )
  |> build.add_hint("Ensure underscores group digits and prefixes match the base.")
  |> build.add_secondary_label(span, Some("`" <> literal <> "` cannot be parsed"))
}

pub fn lex_unknown_escape_sequence(
  file: String,
  source: String,
  span: Span,
  sequence: String,
) -> types.Diagnostic {
  build.error(
    types.Lexing,
    5,
    "Unknown escape sequence",
    file,
    source,
    span,
    Some("unknown escape"),
  )
  |> build.add_hint("Valid escapes include `\\n`, `\\t`, `\\r`, `\\\"`, `\\\\`, and Unicode `\\u{...}`.")
  |> build.add_secondary_label(span, Some("`" <> sequence <> "` is not recognised"))
}

pub fn lex_mixed_indentation(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Lexing,
    101,
    "Mixed indentation detected",
    file,
    source,
    span,
    Some("tabs and spaces are interleaved"),
  )
  |> build.add_hint("Configure your editor to convert tabs to spaces or vice versa.")
}

pub fn lex_trailing_whitespace(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Lexing,
    102,
    "Trailing whitespace",
    file,
    source,
    span,
    Some("whitespace at end of line"),
  )
  |> build.add_hint("Remove trailing spaces to keep diffs clean.")
}

pub fn lex_shebang_ignored(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.info(
    types.Lexing,
    201,
    "Shebang is ignored by the compiler",
    file,
    source,
    span,
    Some("shebang"),
  )
  |> build.add_hint("If you need scripting support, keep the interpreter directive on the first line.")
}

pub fn lex_unicode_normalised(
  file: String,
  source: String,
  span: Span,
  normalised: String,
) -> types.Diagnostic {
  build.info(
    types.Lexing,
    202,
    "Token was normalised to NFC form",
    file,
    source,
    span,
    Some("normalised token"),
  )
  |> build.add_hint("The compiler normalises identifiers to ensure consistent matching.")
  |> build.add_secondary_label(span, Some("Normalised spelling: `" <> normalised <> "`"))
}

/// =============================================
/// PARSING
/// =============================================
pub fn parse_unexpected_token(
  file: String,
  source: String,
  span: Span,
  expected: String,
  found: String,
) -> types.Diagnostic {
  build.error(
    types.Parsing,
    1,
    "Unexpected token encountered",
    file,
    source,
    span,
    Some("unexpected token"),
  )
  |> build.add_hint("Expected " <> expected <> " but got `" <> found <> "`.")
  |> build.add_hint("Check for missing delimiters or stray punctuation earlier in the file.")
}

pub fn parse_unexpected_eof(
  file: String,
  source: String,
  span: Span,
  expected: String,
) -> types.Diagnostic {
  build.error(
    types.Parsing,
    2,
    "Unexpected end of input",
    file,
    source,
    span,
    Some("parser reached end of file"),
  )
  |> build.add_hint("The parser still expected " <> expected <> ". Add the missing code before the file ends.")
}

pub fn parse_missing_delimiter(
  file: String,
  source: String,
  span: Span,
  delimiter: String,
) -> types.Diagnostic {
  build.error(
    types.Parsing,
    3,
    "Missing closing delimiter",
    file,
    source,
    span,
    Some("delimiter opened here"),
  )
  |> build.add_hint("Insert the matching `" <> delimiter <> "` to complete the construct.")
}

pub fn parse_ambiguous_expression(
  file: String,
  source: String,
  span: Span,
  operator: String,
) -> types.Diagnostic {
  build.error(
    types.Parsing,
    4,
    "Ambiguous expression requires parentheses",
    file,
    source,
    span,
    Some("ambiguous use of `" <> operator <> "`"),
  )
  |> build.add_hint("Add parentheses to clarify the intended grouping.")
}

pub fn parse_dangling_else(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Parsing,
    101,
    "Dangling `else` associated with nearest `if`",
    file,
    source,
    span,
    Some("dangling else"),
  )
  |> build.add_hint("Use braces to bind the `else` to a specific branch.")
}

pub fn parse_deprecated_do_block(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Parsing,
    102,
    "`do` blocks are deprecated syntax",
    file,
    source,
    span,
    Some("deprecated syntax"),
  )
  |> build.add_hint("Replace `do` blocks with `async` or `match` constructs.")
}

pub fn parse_recovery_info(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.info(
    types.Parsing,
    201,
    "Parser recovered from an error",
    file,
    source,
    span,
    Some("continuing after recovery"),
  )
  |> build.add_hint("Subsequent errors may be cascaded; fix the first error first.")
}

/// =============================================
/// SYNTAX & AST VALIDATION
/// =============================================
pub fn syntax_duplicate_modifier(
  file: String,
  source: String,
  span: Span,
  modifier: String,
) -> types.Diagnostic {
  build.error(
    types.Syntax,
    1,
    "Modifier specified more than once",
    file,
    source,
    span,
    Some("repeated modifier"),
  )
  |> build.add_secondary_label(span, Some("`" <> modifier <> "` is duplicated"))
  |> build.add_hint("Remove repeated modifiers to avoid ambiguity.")
}

pub fn syntax_conflicting_visibility(
  file: String,
  source: String,
  span: Span,
  first: String,
  second: String,
) -> types.Diagnostic {
  build.error(
    types.Syntax,
    2,
    "Conflicting visibility modifiers",
    file,
    source,
    span,
    Some("conflicting visibility"),
  )
  |> build.add_hint(
    "Visibility modifiers are mutually exclusive. Pick either `" <> first <> "` or `" <> second <> "`.",
  )
}

pub fn syntax_missing_function_body(
  file: String,
  source: String,
  span: Span,
  name: String,
) -> types.Diagnostic {
  build.error(
    types.Syntax,
    3,
    "Function body missing",
    file,
    source,
    span,
    Some("body expected here"),
  )
  |> build.add_hint("Provide an implementation for `" <> name <> "` or mark it as external.")
}

pub fn syntax_unused_semicolon(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Syntax,
    101,
    "Unnecessary trailing semicolon",
    file,
    source,
    span,
    Some("semicolon can be removed"),
  )
  |> build.add_hint("This language uses newline-delimited statements; the semicolon is optional.")
}

pub fn syntax_redundant_parentheses(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Syntax,
    102,
    "Redundant parentheses around expression",
    file,
    source,
    span,
    Some("unnecessary parentheses"),
  )
  |> build.add_hint("Remove extra parentheses to improve readability.")
}

pub fn syntax_implicit_return(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.info(
    types.Syntax,
    201,
    "Expression implicitly returned from function",
    file,
    source,
    span,
    Some("implicit return"),
  )
  |> build.add_hint("Add `return` for clarity if this is not intentional.")
}

pub fn syntax_doc_comment_detached(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.info(
    types.Syntax,
    202,
    "Documentation comment is detached",
    file,
    source,
    span,
    Some("detached doc comment"),
  )
  |> build.add_hint("Documentation comments must be immediately before the item they document.")
}

/// =============================================
/// TYPING
/// =============================================
pub fn type_mismatch(
  file: String,
  source: String,
  span: Span,
  expected: String,
  found: String,
) -> types.Diagnostic {
  build.error(
    types.Typing,
    1,
    "Type mismatch",
    file,
    source,
    span,
    Some("value has type `" <> found <> "`"),
  )
  |> build.add_hint("This expression needs type `" <> expected <> "`.")
  |> build.add_hint("Consider adding an explicit annotation or convert the value.")
}

pub fn type_unknown_identifier(
  file: String,
  source: String,
  span: Span,
  identifier: String,
) -> types.Diagnostic {
  build.error(
    types.Typing,
    2,
    "Unknown identifier",
    file,
    source,
    span,
    Some("identifier not in scope"),
  )
  |> build.add_hint("Did you mean `" <> identifier <> "`? Check imports and spelling.")
}

pub fn type_missing_return(
  file: String,
  source: String,
  span: Span,
  expected: String,
) -> types.Diagnostic {
  build.error(
    types.Typing,
    3,
    "Missing return value",
    file,
    source,
    span,
    Some("function must return `" <> expected <> "`"),
  )
  |> build.add_hint("Ensure all code paths return a value.")
}

pub fn type_recursion_without_base(
  file: String,
  source: String,
  span: Span,
  name: String,
) -> types.Diagnostic {
  build.error(
    types.Typing,
    4,
    "Recursive definition lacks a base case",
    file,
    source,
    span,
    Some("infinite recursion possible"),
  )
  |> build.add_hint("Add a terminating branch to `" <> name <> "`.")
}

pub fn type_unused_type_parameter(
  file: String,
  source: String,
  span: Span,
  parameter: String,
) -> types.Diagnostic {
  build.warning(
    types.Typing,
    101,
    "Unused type parameter",
    file,
    source,
    span,
    Some("`" <> parameter <> "` is never referenced"),
  )
  |> build.add_hint("Remove the parameter or use `_` if it is intentionally unused.")
}

pub fn type_widening_info(
  file: String,
  source: String,
  span: Span,
  from: String,
  to: String,
) -> types.Diagnostic {
  build.info(
    types.Typing,
    201,
    "Implicit type widening applied",
    file,
    source,
    span,
    Some("implicit conversion"),
  )
  |> build.add_hint("Converted `" <> from <> "` to `" <> to <> "` automatically.")
}

pub fn type_constraint_generalised(
  file: String,
  source: String,
  span: Span,
  constraint: String,
) -> types.Diagnostic {
  build.info(
    types.Typing,
    202,
    "Constraint generalised",
    file,
    source,
    span,
    Some("constraint generalised"),
  )
  |> build.add_hint("The inferred type adds constraint `" <> constraint <> "`.")
}

/// =============================================
/// SEMANTIC ANALYSIS
/// =============================================
pub fn semantic_circular_dependency(
  file: String,
  source: String,
  span: Span,
  module_a: String,
  module_b: String,
) -> types.Diagnostic {
  build.error(
    types.Semantic,
    1,
    "Circular module dependency",
    file,
    source,
    span,
    Some("cycle detected"),
  )
  |> build.add_hint("`" <> module_a <> "` depends on `" <> module_b <> "` and vice versa.")
  |> build.add_hint("Break the cycle by extracting shared code or introducing an interface.")
}

pub fn semantic_unreachable_code(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Semantic,
    101,
    "Unreachable code",
    file,
    source,
    span,
    Some("code never executes"),
  )
  |> build.add_hint("Remove the code or restructure control flow.")
}

pub fn semantic_shadowed_binding(
  file: String,
  source: String,
  span: Span,
  name: String,
) -> types.Diagnostic {
  build.warning(
    types.Semantic,
    102,
    "Binding shadows prior definition",
    file,
    source,
    span,
    Some("`" <> name <> "` shadows an outer binding"),
  )
  |> build.add_hint("Rename one of the bindings to avoid confusion.")
}

pub fn semantic_deprecated_module(
  file: String,
  source: String,
  span: Span,
  replacement: String,
) -> types.Diagnostic {
  build.info(
    types.Semantic,
    201,
    "Module is deprecated",
    file,
    source,
    span,
    Some("deprecated module"),
  )
  |> build.add_hint("Use `" <> replacement <> "` instead.")
}

/// =============================================
/// COMPILATION & BACKEND
/// =============================================
pub fn compilation_codegen_failure(
  file: String,
  source: String,
  span: Span,
  stage: String,
) -> types.Diagnostic {
  build.error(
    types.Compilation,
    1,
    "Code generation failure",
    file,
    source,
    span,
    Some("backend error"),
  )
  |> build.add_hint("Backend stage `" <> stage <> "` failed to lower the construct.")
}

pub fn compilation_linker_missing_symbol(
  file: String,
  source: String,
  span: Span,
  symbol: String,
) -> types.Diagnostic {
  build.error(
    types.Compilation,
    2,
    "Missing symbol during linking",
    file,
    source,
    span,
    Some("symbol referenced here"),
  )
  |> build.add_hint("Ensure `" <> symbol <> "` is defined in a linked module or library.")
}

pub fn compilation_backend_warning(
  file: String,
  source: String,
  span: Span,
  detail: String,
) -> types.Diagnostic {
  build.warning(
    types.Compilation,
    101,
    "Backend generated suboptimal code",
    file,
    source,
    span,
    Some("suboptimal code"),
  )
  |> build.add_hint(detail)
}

pub fn compilation_dead_code(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.Compilation,
    102,
    "Dead code eliminated",
    file,
    source,
    span,
    Some("unused construct"),
  )
  |> build.add_hint("Remove unused declarations or export them if they are part of the public API.")
}

pub fn compilation_inlining_hint(
  file: String,
  source: String,
  span: Span,
  function_name: String,
) -> types.Diagnostic {
  build.info(
    types.Compilation,
    201,
    "Function automatically inlined",
    file,
    source,
    span,
    Some("auto inline"),
  )
  |> build.add_hint("`" <> function_name <> "` was inlined to reduce call overhead.")
}

pub fn compilation_debug_info_emitted(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.info(
    types.Compilation,
    202,
    "Debug information emitted",
    file,
    source,
    span,
    Some("debug symbols"),
  )
  |> build.add_hint("Strip symbols in release builds with `--release` or a linker flag if desired.")
}

/// =============================================
/// RUNTIME & GENERAL
/// =============================================
pub fn runtime_unhandled_panic(
  file: String,
  source: String,
  span: Span,
  message: String,
) -> types.Diagnostic {
  build.error(
    types.Runtime,
    1,
    "Unhandled panic will abort program",
    file,
    source,
    span,
    Some("panic triggered here"),
  )
  |> build.add_hint("Wrap the call in a recovery block or handle the error gracefully.")
  |> build.add_hint("Panic message: " <> message)
}

pub fn runtime_missing_capability(
  file: String,
  source: String,
  span: Span,
  capability: String,
) -> types.Diagnostic {
  build.warning(
    types.Runtime,
    101,
    "Runtime capability not available on target platform",
    file,
    source,
    span,
    Some("capability required"),
  )
  |> build.add_hint("Feature `" <> capability <> "` is unavailable; provide a fallback.")
}

pub fn runtime_gc_info(
  file: String,
  source: String,
  span: Span,
  pause_ms: Int,
) -> types.Diagnostic {
  build.info(
    types.Runtime,
    201,
    "Garbage collector pause observed",
    file,
    source,
    span,
    Some("runtime telemetry"),
  )
  |> build.add_hint("Pause duration: " <> int.to_string(pause_ms) <> "ms.")
}

pub fn general_internal_error(
  file: String,
  source: String,
  span: Span,
  bug: String,
) -> types.Diagnostic {
  build.error(
    types.General,
    1,
    "Internal compiler error",
    file,
    source,
    span,
    Some("unexpected compiler state"),
  )
  |> build.add_hint("Please report this bug: " <> bug)
}

pub fn general_todo_warning(
  file: String,
  source: String,
  span: Span,
) -> types.Diagnostic {
  build.warning(
    types.General,
    101,
    "TODO left in source",
    file,
    source,
    span,
    Some("TODO found"),
  )
  |> build.add_hint("Resolve or remove TODO comments before release builds.")
}

pub fn general_note(
  file: String,
  source: String,
  span: Span,
  note: String,
) -> types.Diagnostic {
  build.info(
    types.General,
    201,
    "Note",
    file,
    source,
    span,
    Some("note"),
  )
  |> build.add_hint(note)
}
