import gleam/io
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/pair
import gleam/string
import gleam/string_builder
import gleam/result
import shellout.{StderrToStdout}

pub const truncation_symbol = "~"

pub fn main(args: List(String)) -> NoReturn {
  let color = "automatic"
  let max_width = 15

  let props =
    [
      "avail", "refer", "used", "name", "canmount", "mountpoint", "compression",
      "compressratio", "com.sun:auto-snapshot",
    ]
    |> string.join(with: ",")

  let headers =
    [
      "AVAL", "REF", "USED", "NAME", "MOUNTPOINT", "", "COMPRESSION", "", "ASNAP",
    ]
    |> string.join(with: "\t")
    |> string.append(suffix: "\n")

  let widths = [4, 5, 5, max_width, 6, max_width, 4, 5, 5]

  let colors = [
    "blue", "cyan", "green", "bold yellow", "normal", "normal", "normal",
  ]

  let args = ["list", "-H", "-o", props, "-r", ..args]

  case shellout.cmd("zfs", args, [StderrToStdout(True)]) {
    Ok(tuple(output, status)) -> {
      case status {
        0 -> [headers, ..output]
        _ -> output
      }
      |> iterator.from_list
      |> iterator.map(with: fn(line) { io.print(line) })
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

pub external type NoReturn

pub external fn halt(status: Int) -> NoReturn =
  "erlang" "halt"
