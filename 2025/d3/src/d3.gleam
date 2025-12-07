import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import iv

pub fn main() -> Nil {
  parse_input()
  |> to_list_int
  |> list.map(iv.from_list)
  |> total_biggest
  |> echo

  Nil
}

fn total_biggest(i: List(iv.Array(Int))) -> Int {
  i
  |> list.fold(0, fn(acc, item) {
    let jolts_separate =
      find_biggest_n_times(11, item) |> echo as "result joined"

    let jolts = join_jolts_separate(jolts_separate)

    acc + jolts
  })
}

fn join_jolts_separate(jolts: List(Int)) -> Int {
  let assert Ok(parsed) =
    jolts |> list.map(int.to_string) |> string.join("") |> int.base_parse(10)

  parsed
}

fn find_biggest_n_times(n: Int, item: iv.Array(Int)) -> List(Int) {
  find_biggest_n_times_loop(n, item, 0, [])
}

fn find_biggest_n_times_loop(
  n: Int,
  item: iv.Array(Int),
  count: Int,
  acc: List(BigIndex),
) -> List(Int) {
  case count > n {
    True -> acc |> list.map(pair.first) |> list.reverse()
    False -> {
      let prev_biggest_idx = case list.first(acc) {
        Ok(a) -> pair.second(a) + 1
        Error(_) -> count
      }
      let big =
        find_biggest(item, prev_biggest_idx, iv.length(item) - { n - count })
      find_biggest_n_times_loop(n, item, count + 1, [big, ..acc])
    }
  }
}

type BigIndex =
  #(Int, Int)

fn find_biggest(i: iv.Array(Int), from: Int, till: Int) -> BigIndex {
  echo #(iv.to_list(i), iv.length(i), from) as "item, length, from"
  find_biggest_loop(i, from, till, #(0, -1))
}

fn find_biggest_loop(
  i: iv.Array(Int),
  from: Int,
  till: Int,
  big: BigIndex,
) -> BigIndex {
  case from >= till {
    True -> big
    False -> {
      let assert Ok(elem) = iv.get(i, from) as "should exist"

      let big = case elem > pair.first(big) {
        True -> {
          echo #(elem, from) as "there is a match"
          #(elem, from)
        }
        False -> big
      }

      find_biggest_loop(i, from + 1, till, big)
    }
  }
}

fn to_list_int(batteries: String) -> List(List(Int)) {
  let separated = batteries |> string.split("\n")

  list.take(separated, list.length(separated) - 1)
  |> list.map(fn(i) {
    i
    |> string.split("")
    |> list.map(fn(i) {
      let assert Ok(num) = int.base_parse(i, 10) as "should have valid int"
      num
    })
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
