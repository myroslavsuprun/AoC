import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/pair
import gleam/string

pub fn main() -> Nil {
  parse_input() |> split_to_ranges |> range_to_pair |> process |> echo

  Nil
}

fn process(i: List(FirstLast)) -> Int {
  i
  |> list.fold(0, fn(acc, item) {
    let repeats = count_repeats(pair.second(item), pair.first(item))
    acc + repeats
  })
}

fn count_repeats(end: Int, curr: Int) -> Int {
  count_repeats_loop(end, curr, []) |> int.sum
}

fn count_repeats_loop(end: Int, curr: Int, acc: List(Int)) -> List(Int) {
  case curr > end {
    True -> acc
    False -> {
      let curr_str = int.to_string(curr)
      let len = string.length(curr_str)
      // echo curr as "current value"
      case len != 1 && within_string(len / 2, 1, curr_str) {
        True -> {
          count_repeats_loop(end, curr + 1, [curr, ..acc])
        }
        False -> count_repeats_loop(end, curr + 1, acc)
      }
    }
  }
}

fn within_string(till: Int, curr: Int, num: String) -> Bool {
  let part = string.slice(num, 0, curr)

  let repeats = string.repeat(part, string.length(num) / string.length(part))

  case curr == till {
    True -> {
      case repeats == num {
        True -> {
          // echo #(repeats, num) as "matched last"

          True
        }
        False -> False
      }
    }
    False -> {
      case repeats == num {
        True -> {
          // echo #(repeats, num) as "matched"
          True
        }
        False -> within_string(till, curr + 1, num)
      }
    }
  }
}

type FirstLast =
  #(Int, Int)

fn range_to_pair(input: List(String)) -> List(FirstLast) {
  input
  |> list.map(fn(i) {
    let ints = string.split(i, "-")

    case ints {
      [a, b] -> {
        let assert Ok(int1) = int.base_parse(a, 10)
        let assert Ok(int2) = int.base_parse(b, 10)
        #(int1, int2)
      }
      _ -> panic as "oh no"
    }
  })
}

fn split_to_ranges(input: String) -> List(String) {
  input |> string.replace("\n", "") |> string.split(",")
}

fn parse_input() -> String {
  let filename = "input.txt"

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
