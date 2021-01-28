import gleam/list.{Continue, Stop}
import gleam/pair
import gleam/string
import gleam/string_builder

type Truncator {
  Truncator(
    builder: List(String),
    foot_index: Int,
    graphemes: Int,
    index: Int,
    length: Int,
    path_parts: List(String),
    prefix: Bool,
    symbol: String,
  )
}

pub fn truncate(path, to length, with symbol) {
  let path_parts = string.split(path, on: "/")

  let truncator =
    Truncator(
      builder: [],
      foot_index: list.length(path_parts) - 1,
      graphemes: string.length(path),
      index: 0,
      length: length,
      path_parts: path_parts,
      prefix: False,
      symbol: symbol,
    )

  truncator.path_parts
  |> list.fold_until(
    from: truncator,
    with: truncate_helper,
  )
  |> truncate_end
}

fn truncate_helper(item, truncator) {
  let item_length = string.length(item)

  let is_foot = truncator.foot_index == truncator.index
  let is_long = truncator.length < truncator.graphemes
  let is_solo = 0 == truncator.foot_index

  let item = case is_foot, is_long, is_solo {
    _, False, _ -> item
    False, True, _ -> string.slice(from: item, at_index: 0, length: 1)
    True, True, True ->
      item
      |> string.slice(at_index: 0, length: truncator.length - 1)
      |> string_builder.from_string
      |> string_builder.append(truncator.symbol)
      |> string_builder.to_string
    True, _, False -> {
      let is_long_foot = 0 < item_length - truncator.length - 1
      case is_long_foot {
        False -> item
        True ->
          item
          |> string.slice(at_index: 0, length: truncator.length - 2)
          |> string_builder.from_string
          |> string_builder.prepend(truncator.symbol)
          |> string_builder.append(truncator.symbol)
          |> string_builder.to_string
      }
    }
  }

  let truncator =
    Truncator(
      ..truncator,
      builder: [item, ..truncator.builder],
      graphemes: truncator.graphemes + string.length(item) - item_length,
      index: 1 + truncator.index,
    )

  let is_done = truncator.length >= truncator.graphemes
  case is_done || is_foot {
    False -> Continue(truncator)
    True -> {
      let remainder =
        truncator.path_parts
        |> list.split(at: truncator.index)
        |> pair.second
      let is_truncated = string.length(item) < item_length && False == is_solo
      Stop(
        Truncator(
          ..truncator,
          path_parts: truncator.builder
          |> list.reverse
          |> list.append(remainder),
          prefix: is_truncated,
        ),
      )
    }
  }
}

fn truncate_end(with truncator) {
  truncator.path_parts
  |> list.intersperse(with: "/")
  |> string_builder.from_strings
  |> string_builder.prepend(
    case truncator.prefix {
      True -> truncator.symbol
      False -> ""
    }
  )
  |> string_builder.to_string
  |> fn(path) {
    let extra = 1 + truncator.graphemes - truncator.length
    case truncator.prefix && extra > 0 {
      False -> path
      True -> {
        let extra =
          path
          |> string.slice(at_index: 1, length: extra)
        path
        |> string.split_once(on: extra)
        |> fn(result) {
          assert Ok(tuple(to, suffix)) = result
          string.append(to, suffix)
        }
      }
    }
  }
}

pub external type NoReturn

pub external fn halt(status: Int) -> NoReturn =
  "erlang" "halt"
