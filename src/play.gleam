import clarity/diagnostics as diagnostics
import clarity/diagnostics/messages
import gleam/io
import gleam/list

const example_dir = "examples/"

pub fn main() -> Nil {
  let palette = diagnostics.default_style()
  let diagnostics_to_render = [
    lex_unexpected_character_example(),
    lex_trailing_whitespace_example(),
    lex_shebang_ignored_example(),
    lex_unknown_escape_example(),
    lex_invalid_number_example(),
    parse_missing_delimiter_example(),
    parse_unexpected_token_example(),
    parse_dangling_else_example(),
    parse_recovery_info_example(),
    syntax_duplicate_modifier_example(),
    syntax_unused_semicolon_example(),
    syntax_doc_comment_detached_example(),
    typing_type_mismatch_example(),
    typing_unknown_identifier_example(),
    typing_missing_return_example(),
    typing_unused_type_parameter_example(),
    typing_widening_example(),
    semantic_circular_dependency_example(),
    semantic_unreachable_code_example(),
    semantic_shadowed_binding_example(),
    compilation_codegen_failure_example(),
    compilation_linker_missing_symbol_example(),
    compilation_backend_warning_example(),
    compilation_dead_code_example(),
    compilation_inlining_hint_example(),
    runtime_unhandled_panic_example(),
    runtime_missing_capability_example(),
    runtime_gc_info_example(),
    general_internal_error_example(),
    general_todo_warning_example(),
    general_note_example(),
  ]

  diagnostics_to_render
  |> list.each(fn(diagnostic) {
    io.println(diagnostics.render(diagnostic, palette))
    io.println("")
  })
}

/// =============================================
/// LEXER EXAMPLES
/// =============================================
fn lex_unexpected_character_example() -> diagnostics.Diagnostic {
  let source = "let name = @unknown\n"
  messages.lex_unexpected_character(
    example_file("lexer.clr"),
    source,
    diagnostics.span_on_line(1, 12, 1),
    "@",
  )
}

fn lex_trailing_whitespace_example() -> diagnostics.Diagnostic {
  let source = "let trailing = 1  \n"
  messages.lex_trailing_whitespace(
    example_file("lexer.clr"),
    source,
    diagnostics.span_on_line(1, 17, 2),
  )
}

fn lex_shebang_ignored_example() -> diagnostics.Diagnostic {
  let source = "#!/usr/bin/env clarity\nmain()\n"
  messages.lex_shebang_ignored(
    example_file("lexer_script.clr"),
    source,
    diagnostics.span_on_line(1, 1, 2),
  )
}

fn lex_unknown_escape_example() -> diagnostics.Diagnostic {
  let source = "\"bad\\qescape\"\n"
  messages.lex_unknown_escape_sequence(
    example_file("lexer.clr"),
    source,
    diagnostics.span_on_line(1, 5, 2),
    "\\q",
  )
}

fn lex_invalid_number_example() -> diagnostics.Diagnostic {
  let source = "let value = 0x_Z12\n"
  messages.lex_invalid_numeric_literal(
    example_file("lexer.clr"),
    source,
    diagnostics.span_on_line(1, 13, 5),
    "0x_Z12",
  )
}

/// =============================================
/// PARSER EXAMPLES
/// =============================================
fn parse_missing_delimiter_example() -> diagnostics.Diagnostic {
  let source = "if flag {\n  work()\n"
  messages.parse_missing_delimiter(
    example_file("parser.clr"),
    source,
    diagnostics.span_on_line(1, 8, 1),
    "}",
  )
}

fn parse_unexpected_token_example() -> diagnostics.Diagnostic {
  let source = "let items = [1, 2, 3,)\n"
  messages.parse_unexpected_token(
    example_file("parser.clr"),
    source,
    diagnostics.span_on_line(1, 21, 1),
    "closing `]`",
    ")",
  )
}

fn parse_dangling_else_example() -> diagnostics.Diagnostic {
  let source =
    "if check {\n"
    <> "  if other {\n"
    <> "    run()\n"
    <> "  }\n"
    <> "else {\n"
    <> "  cleanup()\n"
  messages.parse_dangling_else(
    example_file("parser.clr"),
    source,
    diagnostics.span_on_line(5, 1, 4),
  )
}

fn parse_recovery_info_example() -> diagnostics.Diagnostic {
  let source = "fn broken( -> Nil {\n  pass\n}\n"
  messages.parse_recovery_info(
    example_file("parser.clr"),
    source,
    diagnostics.span_on_line(1, 4, 2),
  )
}

/// =============================================
/// SYNTAX EXAMPLES
/// =============================================
fn syntax_duplicate_modifier_example() -> diagnostics.Diagnostic {
  let source = "pub pub fn bad() { 1 }\n"
  messages.syntax_duplicate_modifier(
    example_file("syntax.clr"),
    source,
    diagnostics.span_on_line(1, 1, 7),
    "pub",
  )
}

fn syntax_unused_semicolon_example() -> diagnostics.Diagnostic {
  let source = "let answer = 42;\n"
  messages.syntax_unused_semicolon(
    example_file("syntax.clr"),
    source,
    diagnostics.span_on_line(1, 15, 1),
  )
}

fn syntax_doc_comment_detached_example() -> diagnostics.Diagnostic {
  let source = "/// Docs\n\nfn real() { 1 }\n"
  messages.syntax_doc_comment_detached(
    example_file("syntax.clr"),
    source,
    diagnostics.span_on_line(1, 1, 7),
  )
}

/// =============================================
/// TYPING EXAMPLES
/// =============================================
fn typing_type_mismatch_example() -> diagnostics.Diagnostic {
  let source = "let count: Int = \"five\"\n"
  messages.type_mismatch(
    example_file("typing.clr"),
    source,
    diagnostics.span_on_line(1, 17, 6),
    "Int",
    "String",
  )
}

fn typing_unknown_identifier_example() -> diagnostics.Diagnostic {
  let source = "let result = missing_value + 1\n"
  messages.type_unknown_identifier(
    example_file("typing.clr"),
    source,
    diagnostics.span_on_line(1, 13, 13),
    "missing_value",
  )
}

fn typing_missing_return_example() -> diagnostics.Diagnostic {
  let source =
    "fn compute(flag: Bool) -> Int {\n"
    <> "  if flag {\n"
    <> "    1\n"
    <> "  }\n"
  messages.type_missing_return(
    example_file("typing.clr"),
    source,
    diagnostics.span(1, 1, 4, 3),
    "Int",
  )
}

fn typing_unused_type_parameter_example() -> diagnostics.Diagnostic {
  let source = "fn wrap(a: a) -> Int { 1 }\n"
  messages.type_unused_type_parameter(
    example_file("typing.clr"),
    source,
    diagnostics.span_on_line(1, 9, 1),
    "a",
  )
}

fn typing_widening_example() -> diagnostics.Diagnostic {
  let source = "let precise: Float = 1\n"
  messages.type_widening_info(
    example_file("typing.clr"),
    source,
    diagnostics.span_on_line(1, 22, 1),
    "Int",
    "Float",
  )
}

/// =============================================
/// SEMANTIC EXAMPLES
/// =============================================
fn semantic_circular_dependency_example() -> diagnostics.Diagnostic {
  let source = "import other/module\n"
  messages.semantic_circular_dependency(
    example_file("semantic.clr"),
    source,
    diagnostics.span_on_line(1, 1, 18),
    "semantic.module",
    "other.module",
  )
}

fn semantic_unreachable_code_example() -> diagnostics.Diagnostic {
  let source =
    "fn logic() {\n"
    <> "  return 0\n"
    <> "  warn()\n"
  messages.semantic_unreachable_code(
    example_file("semantic.clr"),
    source,
    diagnostics.span_on_line(3, 3, 6),
  )
}

fn semantic_shadowed_binding_example() -> diagnostics.Diagnostic {
  let source =
    "let value = 10\n"
    <> "fn demo(value: Int) {\n"
    <> "  value + 1\n"
  messages.semantic_shadowed_binding(
    example_file("semantic.clr"),
    source,
    diagnostics.span_on_line(2, 4, 5),
    "value",
  )
}

/// =============================================
/// COMPILATION EXAMPLES
/// =============================================
fn compilation_codegen_failure_example() -> diagnostics.Diagnostic {
  let source = "external fn unreachable() -> Int\n"
  messages.compilation_codegen_failure(
    example_file("compilation.clr"),
    source,
    diagnostics.span_on_line(1, 1, 8),
    "lowering",
  )
}

fn compilation_linker_missing_symbol_example() -> diagnostics.Diagnostic {
  let source = "foreign call missing_symbol()\n"
  messages.compilation_linker_missing_symbol(
    example_file("compilation.clr"),
    source,
    diagnostics.span_on_line(1, 14, 14),
    "missing_symbol",
  )
}

fn compilation_backend_warning_example() -> diagnostics.Diagnostic {
  let source = "fn heavy() { loop_forever() }\n"
  messages.compilation_backend_warning(
    example_file("compilation.clr"),
    source,
    diagnostics.span_on_line(1, 1, 2),
    "Loop could not be vectorised; consider refactoring.",
  )
}

fn compilation_dead_code_example() -> diagnostics.Diagnostic {
  let source =
    "fn helper() {\n"
    <> "  let unused = compute()\n"
    <> "  unused\n"
  messages.compilation_dead_code(
    example_file("compilation.clr"),
    source,
    diagnostics.span_on_line(2, 3, 9),
  )
}

fn compilation_inlining_hint_example() -> diagnostics.Diagnostic {
  let source = "fn tiny() { 1 }\n"
  messages.compilation_inlining_hint(
    example_file("compilation.clr"),
    source,
    diagnostics.span_on_line(1, 4, 4),
    "tiny",
  )
}

/// =============================================
/// RUNTIME & GENERAL EXAMPLES
/// =============================================
fn runtime_unhandled_panic_example() -> diagnostics.Diagnostic {
  let source = "panic(\"boom\")\n"
  messages.runtime_unhandled_panic(
    example_file("runtime.clr"),
    source,
    diagnostics.span_on_line(1, 1, 5),
    "boom",
  )
}

fn runtime_missing_capability_example() -> diagnostics.Diagnostic {
  let source = "enable_feature(\"threads\")\n"
  messages.runtime_missing_capability(
    example_file("runtime.clr"),
    source,
    diagnostics.span_on_line(1, 1, 6),
    "threads",
  )
}

fn runtime_gc_info_example() -> diagnostics.Diagnostic {
  let source = "gc_pause_ms(64)\n"
  messages.runtime_gc_info(
    example_file("runtime.clr"),
    source,
    diagnostics.span_on_line(1, 1, 12),
    64,
  )
}

fn general_internal_error_example() -> diagnostics.Diagnostic {
  let source = "raise_internal_bug()\n"
  messages.general_internal_error(
    example_file("general.clr"),
    source,
    diagnostics.span_on_line(1, 1, 18),
    "Unexpected nil pointer during symbol resolution.",
  )
}

fn general_todo_warning_example() -> diagnostics.Diagnostic {
  let source = "// TODO: handle edge cases\n"
  messages.general_todo_warning(
    example_file("general.clr"),
    source,
    diagnostics.span_on_line(1, 4, 4),
  )
}

fn general_note_example() -> diagnostics.Diagnostic {
  let source = "fn experimental() { 42 }\n"
  messages.general_note(
    example_file("general.clr"),
    source,
    diagnostics.span_on_line(1, 1, 2),
    "Enable `--experimental` to use this API.",
  )
}

fn example_file(name: String) -> String {
  example_dir <> name
}
