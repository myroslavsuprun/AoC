import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

pub fn exec_part1() -> Result(Nil, Nil) {
  use i <- result.try(parse_input())

  i
  |> get_valid_muls
  |> get_multiplied_nums
  |> list.fold(0, add)
  |> echo

  Ok(Nil)
}

fn add(a, b) {
  a + b
}

fn get_valid_muls(v: String) -> List(String) {
  let assert Ok(reg) = regexp.from_string("mul\\(\\d*,\\d*\\)")

  regexp.scan(reg, v)
  |> list.map(fn(match) { match.content })
}

fn get_multiplied_nums(muls: List(String)) -> List(Int) {
  let assert Ok(reg) = regexp.from_string("\\d*,\\d*")

  muls
  |> list.map(regexp.scan(reg, _))
  |> list.map(fn(m) {
    let assert [match] = m
    let #(a, b) = split_to_nums(match.content)
    a * b
  })
}

fn split_to_nums(str: String) -> #(Int, Int) {
  let assert [first, second] =
    str |> string.split(",") |> list.map(int.base_parse(_, 10)) |> result.values

  #(first, second)
}

fn parse_input() -> Result(String, Nil) {
  let filename = "input.txt"

  case file_stream.open_read(filename) {
    Ok(stream) -> get_lines_loop(stream, "")
    Error(_) -> Error(Nil)
  }
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
