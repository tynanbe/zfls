import gleam/int
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/pair
import gleam/regex.{Match}
import gleam/string
import gleam/string_builder

const part_pattern = "([/\\\\]*)([^/\\\\]*)"

pub fn truncate(path, to length, with symbol) {
  assert Ok(re) = regex.from_string(part_pattern)
  let path = normalize(path)

  let initial = tuple(string.length(path), string_builder.from_string(""))

  let output =
    path
    |> regex.scan(with: re)
    |> iterator.from_list
    |> iterator.map(with: fn(item) {
      let Match(submatches: submatches, ..) = item
      submatches
    })

  let tuple(basename_index, "", basename) =
    output
    |> iterator.fold(
      from: tuple(-1, "", ""),
      with: fn(item, acc) {
        let tuple(index, prev_delimiter, prev_part) = acc
        let [delimiter, part] = item
        case part {
          Some(_) -> tuple(
            1 + index,
            option.unwrap(delimiter, or: ""),
            option.unwrap(part, or: ""),
          )
          None -> tuple(
            index,
            "",
            case delimiter {
              Some(delimiter) -> [prev_delimiter, prev_part, delimiter]
              None -> [prev_delimiter, prev_part]
            }
            |> string_builder.from_strings
            |> string_builder.to_string,
          )
        }
      },
    )

  let tuple(noop_index, output) = case length < string.length(basename) {
    True -> tuple(
      0,
      [
        [
          None,
          Some(
            [
              string.slice(
                from: basename,
                at_index: 0,
                length: length - int.min(2, 1 + basename_index),
              ),
              symbol,
            ]
            |> string_builder.from_strings
            |> string_builder.to_string,
          ),
        ],
      ]
      |> iterator.from_list,
    )
    False -> tuple(basename_index, output)
  }

  let output =
    output
    |> iterator.to_list
    |> list.index_fold(
      from: initial,
      with: fn(index, item, acc) {
        let tuple(graphemes, builder) = acc
        let [delimiter, part] = item

        let part = option.unwrap(part, or: "")
        let should_truncate =
          noop_index > index && {
            length < graphemes || length == graphemes && pair.first(initial) > graphemes
          }
        let tuple(graphemes, part) = case should_truncate {
          True -> tuple(
            graphemes - string.length(part) + 1,
            string.slice(from: part, at_index: 0, length: 1),
          )
          False -> tuple(graphemes, part)
        }

        tuple(
          graphemes,
          builder
          |> string_builder.append(option.unwrap(delimiter, or: ""))
          |> string_builder.append(part),
        )
      },
    )
    |> pair.second
    |> string_builder.to_string

  case path == output || 0 == basename_index {
    True -> [output]
    False -> [symbol, output]
  }
  |> string_builder.from_strings
  |> string_builder.to_string
}

pub fn normalize(path) {
  assert Ok(re) = regex.from_string(part_pattern)
  let initial = string_builder.from_string("")

  path
  |> regex.scan(with: re)
  |> list.fold(
    from: initial,
    with: fn(item, acc) {
      let Match(submatches: [delimiter, part], ..) = item

      let delimiter = case delimiter {
        Some(delimiter) -> string.slice(from: delimiter, at_index: 0, length: 1)
        None -> ""
      }

      acc
      |> string_builder.append(delimiter)
      |> string_builder.append(option.unwrap(part, or: ""))
    },
  )
  |> string_builder.to_string
}

pub external type NoReturn

pub external fn halt(status: Int) -> NoReturn =
  "erlang" "halt"
