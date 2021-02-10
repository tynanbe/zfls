import gleam/bool
import gleam/function
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import gleam/string_builder
import shellout.{StderrToStdout}
import cli/path.{NoReturn, halt}

pub const truncation_symbol = "~"

pub fn main(args: List(String)) -> NoReturn {
  let color = "automatic"
  let max_width = 15

  let props = [
    "avail", "refer", "used", "name", "canmount", "mountpoint", "compression", "compressratio",
    "com.sun:auto-snapshot",
  ]

  let headers = [
    "AVAL", "REF", "USED", "NAME", "MOUNTPOINT", "", "COMPRESSION", "", "ASNAP",
  ]

  let widths = [4, 5, 5, max_width, 6, max_width, 4, 5, 5]

  let colors = [
    "blue", "cyan", "green", "bold yellow", "normal", "normal", "normal",
  ]

  let format = list.zip(props, widths)

  let args = [
    "list",
    "-H",
    "-o",
    props
    |> list.intersperse(with: ",")
    |> string_builder.from_strings
    |> string_builder.to_string,
    "-r",
    ..args
  ]

  case shellout.cmd("zfs", args, [StderrToStdout(True)]) {
    Ok(tuple(output, status)) -> {
      case 0 == status {
        False -> iterator.from_list(output)
        True -> {
          let headers =
            [
              headers
              |> list.zip(widths)
              |> list.fold(
                from: [],
                with: fn(item, acc) {
                  let tuple(header, width) = item
                  case header {
                    "" -> {
                      let [tuple(prev_header, prev_width), ..tail] = acc
                      [tuple(prev_header, prev_width + width + 2), ..tail]
                    }
                    _ -> [item, ..acc]
                  }
                },
              )
              |> list.reverse,
            ]
            |> iterator.from_list
          let output =
            output
            |> iterator.from_list
            |> iterator.flat_map(with: fn(item) {
              item
              |> string.split(on: "\n")
              |> iterator.from_list
            })
            |> iterator.filter(for: function.compose(
              string.is_empty,
              bool.negate,
            ))
            |> iterator.map(with: fn(line) {
              line
              |> string.split("\t")
              |> list.zip(format)
              |> list.map(with: fn(item) {
                let tuple(item, tuple(prop, width)) = item
                tuple(case prop {
                    "name" | "mountpoint" ->
                      item
                      |> path.truncate(to: max_width, with: truncation_symbol)
                    _ -> item
                  }, width)
              })
            })
          headers
          |> iterator.append(output)
          |> iterator.map(with: fn(line) {
            line
            |> list.map(with: fn(item) {
              let tuple(item, width) = item
              item
              |> string.pad_right(to: width, with: " ")
            })
            |> string.join(with: "  ")
          })
        }
      }
      |> iterator.map(with: io.println)
      |> iterator.run
      status
    }

    Error(reason) -> {
      io.println(reason)
      1
    }
  }
  |> halt
}
