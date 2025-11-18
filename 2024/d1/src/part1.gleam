import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

type LocationLists =
  #(List(Int), List(Int))

pub fn exec_part1() -> Result(Nil, Nil) {
  use lines <- result.try(parse_input())
  let location_lists = get_sorted_ints(lines)

  let first = pair.first(location_lists)
  let second = pair.second(location_lists)
  echo substract_locations(first, second)

  Ok(Nil)
}

fn substract_locations(list1: List(Int), list2: List(Int)) -> Int {
  substract_locations_loop(list1, list2, 0)
}

fn substract_locations_loop(list1: List(Int), list2: List(Int), acc: Int) -> Int {
  case list1, list2 {
    [x1, ..rest1], [x2, ..rest2] ->
      substract_locations_loop(rest1, rest2, acc + int.absolute_value(x2 - x1))
    _, _ -> acc
  }
}

pub fn get_sorted_ints(lines: List(String)) -> LocationLists {
  let pairs = list.filter_map(lines, parse_line)

  let first = list.map(pairs, pair.first) |> list.sort(int.compare)
  let second = list.map(pairs, pair.second) |> list.sort(int.compare)
  pair.new(first, second)
}

fn parse_line(line: String) -> Result(#(Int, Int), Nil) {
  string.replace(line, "\n", "")
  |> string.split("   ")
  |> get_string_pair
  |> result.try(parse_string_pair_to_int)
}

fn get_string_pair(ints: List(String)) -> Result(#(String, String), Nil) {
  case ints {
    [first, second, ..] -> Ok(pair.new(first, second))
    [] -> Error(Nil)
    [_] -> Error(Nil)
  }
}

fn parse_string_pair_to_int(ints: #(String, String)) -> Result(#(Int, Int), Nil) {
  use first <- result.try(int.base_parse(pair.first(ints), 10))
  use second <- result.try(int.base_parse(pair.second(ints), 10))

  Ok(pair.new(first, second))
}

pub fn parse_input() -> Result(List(String), Nil) {
  let filename = "input.txt"

  case file_stream.open_read(filename) {
    Ok(stream) -> get_lines_loop(stream, [])
    Error(_) -> Error(Nil)
  }
}

fn get_lines_loop(
  stream: file_stream.FileStream,
  acc: List(String),
) -> Result(List(String), Nil) {
  case file_stream.read_line(stream) {
    Ok(line) -> get_lines_loop(stream, [line, ..acc])
    Error(file_stream_error.Eof) -> Ok(acc)
    Error(_) -> Error(Nil)
  }
}
