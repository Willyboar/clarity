/// Source code positioning helpers used by the diagnostics system.
///
/// A position identifies a UTF-8 column within a 1-indexed line. Spans cover
/// half-open ranges `[start, end)` where the `end` column points just past the
/// final highlighted character. This makes it simple to derive the caret
/// underline width when rendering diagnostics.

/// 1-indexed line/column pair.
pub type Position {
  Position(line: Int, column: Int)
}

/// Inclusive start, exclusive end span.
pub type Span {
  Span(start: Position, end: Position)
}

/// Construct a position using 1-indexed line and column values.
pub fn position(line: Int, column: Int) -> Position {
  Position(line: line, column: column)
}

/// Convenience constructor for spans covering a single token.
pub fn span(start_line: Int, start_column: Int, end_line: Int, end_column: Int) -> Span {
  Span(
    start: Position(line: start_line, column: start_column),
    end: Position(line: end_line, column: end_column),
  )
}

/// Shorthand for creating a span on a single line of given width.
pub fn span_on_line(line: Int, start_column: Int, width: Int) -> Span {
  span(line, start_column, line, start_column + width)
}

/// Merge two spans to form an enclosing span. Useful when highlighting ranges.
pub fn merge(left: Span, right: Span) -> Span {
  let Span(start: left_start, end: left_end) = left
  let Span(start: right_start, end: right_end) = right
  Span(
    start: earlier(left_start, right_start),
    end: later(left_end, right_end),
  )
}

fn earlier(a: Position, b: Position) -> Position {
  case compare(a, b) {
    -1 -> a
    0 -> a
    _ -> b
  }
}

fn later(a: Position, b: Position) -> Position {
  case compare(a, b) {
    1 -> a
    0 -> b
    _ -> b
  }
}

/// Compare two positions. Returns -1 if `a` is earlier, 1 if later, and 0 when
/// they are the same.
pub fn compare(a: Position, b: Position) -> Int {
  let Position(line: line_a, column: column_a) = a
  let Position(line: line_b, column: column_b) = b
  case line_a - line_b {
    0 -> compare_columns(column_a, column_b)
    diff if diff < 0 -> -1
    _ -> 1
  }
}

fn compare_columns(a: Int, b: Int) -> Int {
  case a - b {
    0 -> 0
    diff if diff < 0 -> -1
    _ -> 1
  }
}
