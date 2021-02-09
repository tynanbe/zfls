import gleam/should
import gleam/string_builder
import cli/path

// path.truncate/3
pub const length = 9

pub const symbol = "~"

pub fn truncate_solo_lt_test() {
  let path = "abcdefgh"
  path.truncate(path, length, symbol)
  |> should.equal(path)
}

pub fn truncate_solo_eq_test() {
  let path = "abcdefghi"
  path.truncate(path, length, symbol)
  |> should.equal(path)
}

pub fn truncate_solo_gt_test() {
  path.truncate("abcdefghij", length, symbol)
  |> should.equal(
    ["abcdefgh", symbol]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_solo_gt_leading_slash_test() {
  path.truncate("/abcdefghi", length, symbol)
  |> should.equal(
    ["/abcdefg", symbol]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_solo_gt_trailing_slash_test() {
  path.truncate("abcdefghi/", length, symbol)
  |> should.equal(
    ["abcdefgh", symbol]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_has_parent_lt_test() {
  let path = "abc/defg"
  path.truncate(path, length, symbol)
  |> should.equal(path)
}

pub fn truncate_has_parent_eq_test() {
  let path = "abc/defgh"
  path.truncate(path, length, symbol)
  |> should.equal(path)
}

pub fn truncate_has_parent_gt_test() {
  path.truncate("abc/defghi", length, symbol)
  |> should.equal(
    [symbol, "a/defghi"]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_one_part_test() {
  path.truncate("abc/de/fgh", length, symbol)
  |> should.equal(
    [symbol, "a/de/fgh"]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_some_parts_test() {
  path.truncate("abcd/efg/hi/jk", length, symbol)
  |> should.equal(
    [symbol, "a/e/h/jk"]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}

pub fn truncate_all_parts_test() {
  path.truncate("abcd/efg/hi/jklmnopqrst", length, symbol)
  |> should.equal(
    [symbol, "/jklmno", symbol]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}
