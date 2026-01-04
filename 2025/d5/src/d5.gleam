import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/pair
import gleam/string

pub fn main() -> Nil {
  parse_input()
  |> split_lines
  // |> count_fresh
  |> count_fresh_ranges
  // |> echo
  Nil
}

type Fresh =
  List(#(Int, Int))

type I =
  #(Fresh, List(Int))

fn count_fresh_ranges(i: I) {
  sort_ranges(i.0) |> merge_ranges |> sum_ranges
}

fn sum_ranges(f: Fresh) -> Int {
  use acc, r <- list.fold(f, 0)

  r.1 - r.0 + acc + 1
}

fn merge_ranges(f: Fresh) -> Fresh {
  use acc, curr <- list.fold(f, [])

  case acc {
    [] -> [curr]
    [last, ..rest] -> {
      let #(f1, s1) = last
      let #(f2, s2) = curr

      case int.compare(f2, s1) {
        Lt | Eq -> [#(f1, int.max(s1, s2)), ..rest]
        Gt -> [curr, last, ..rest]
      }
    }
  }
}

fn sort_ranges(f: Fresh) -> Fresh {
  use a, b <- list.sort(f)
  case int.compare(a.0, b.0) {
    Eq -> int.compare(a.1, b.1)
    other -> other
  }
}

fn count_fresh(i: I) {
  let fresh = pair.first(i)
  let items = pair.second(i)

  items
  |> list.fold(0, fn(acc, i) {
    case in_fresh(fresh, i) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn in_fresh(fresh: List(#(Int, Int)), i: Int) -> Bool {
  case fresh {
    [range, ..rest] -> {
      let f = pair.first(range)
      let s = pair.second(range)
      case i >= f && i <= s {
        True -> True
        False -> in_fresh(rest, i)
      }
    }
    [] -> False
  }
}

fn split_lines(str: String) -> I {
  let assert [first, second] =
    str
    |> string.split("\n\n")
    |> list.map(fn(item) { item |> string.split("\n") })
    as "valid parsed two parts"

  let first_part = split_lines_first_part(first) |> list.reverse()
  let second_part = split_lines_second_part(second)

  #(first_part, second_part)
}

fn split_lines_first_part(first: List(String)) -> List(#(Int, Int)) {
  first
  |> list.fold([], fn(acc, item) {
    let assert [first, second] = item |> string.split("-") as "first and second"
    let assert Ok(f_int) = int.base_parse(first, 10)
    let assert Ok(s_int) = int.base_parse(second, 10)

    [#(f_int, s_int), ..acc]
  })
}

fn split_lines_second_part(second: List(String)) -> List(Int) {
  second
  |> list.take(list.length(second) - 1)
  |> list.map(fn(item) {
    let assert Ok(result) = item |> int.base_parse(10)
      as "should correctly parsed to int"

    result
  })
}

fn parse_input() -> String {
  let filename = "input_mine.txt"

  let assert Ok(stream) = file_stream.open_read(filename)
    as "should open the file"
  let assert Ok(lines) = get_lines_loop(stream, "")
    as "should correctly parse lines"

  lines
}

fn get_lines_loop(
  stream: file_stream.FileStream,
  acc: String,
) -> Result(String, Nil) {
  case file_stream.read_line(stream) {
    Ok(line) -> get_lines_loop(stream, acc <> line)
    Error(file_stream_error.Eof) -> Ok(acc)
    Error(_) -> Error(Nil)
  }
}
