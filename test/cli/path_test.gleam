import gleam/should
import gleam/string_builder
import cli/path

pub fn normalize_root_test() {
  let path = "/"
  path.normalize(path)
  |> should.equal(path)
}

pub fn normalize_slash_test() {
  path.normalize("//foo//")
  |> should.equal("/foo/")
}

pub fn normalize_backslash_test() {
  path.normalize("\\\\foo\\\\")
  |> should.equal("\\foo\\")
}

pub fn normalize_dos_drive_letter_test() {
  let path = "C:"
  path.normalize(path)
  |> should.equal(path)
}

pub fn normalize_dos_drive_root_test() {
  let path = "C:\\"
  path.normalize(path)
  |> should.equal(path)
}

pub fn normalize_dos_backslash_test() {
  path.normalize("C:\\\\foo")
  |> should.equal("C:\\foo")
}

pub fn normalize_dos_slash_test() {
  path.normalize("C://foo")
  |> should.equal("C:/foo")
}

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

pub fn truncate_trim_left_test() {
  path.truncate("ab/cd/ef/gh/ijk", length, symbol)
  |> should.equal(
    [symbol, "/e/g/ijk"]
    |> string_builder.from_strings
    |> string_builder.to_string,
  )
}
