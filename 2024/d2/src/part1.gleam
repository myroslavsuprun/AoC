import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

type Record =
  List(Int)

type Dir {
  Up
  Down
}

pub fn exec_part1() -> Nil {
  let _ =
    parse_input()
    |> result.try(to_reports)
    |> result.map(get_safe_records)
  Nil
}

fn get_safe_records(levels: List(Record)) -> Int {
  levels
  |> list.filter(is_safe_record)
  |> list.length
  |> echo
}

fn is_safe_record(r: Record) -> Bool {
  echo #("record", r)
  let res = is_safe_record_loop(r, None, None)
  echo #("result", res)

  res
}

fn is_safe_record_loop(
  l: List(Int),
  prev: Option(Int),
  dir: Option(Dir),
) -> Bool {
  case l {
    [] -> True
    [c, ..rest] -> {
      is_it_safe_inner_loop(rest, prev, c, dir)
    }
  }
}

fn is_it_safe_inner_loop(
  rest: List(Int),
  prev: Option(Int),
  curr: Int,
  dir: Option(Dir),
) -> Bool {
  case prev {
    Some(p) -> {
      let subt = int.absolute_value({ p - curr })
      case subt > 3 || subt == 0 {
        True -> False
        False -> {
          matches_dir(dir, p, curr)
          && is_safe_record_loop(
            rest,
            Some(curr),
            option.lazy_or(dir, fn() { Some(get_dir(p, curr)) }),
          )
        }
      }
    }
    None -> is_safe_record_loop(rest, Some(curr), None)
  }
}

fn matches_dir(dir: Option(Dir), a, b) -> Bool {
  let res = case dir {
    Some(d) if a - b >= 0 -> d == Down
    Some(d) -> d == Up
    None -> True
  }

  echo #(res, dir, a, b)

  res
}

fn get_dir(a: Int, b: Int) -> Dir {
  case a <= b {
    True -> Up
    False -> Down
  }
}

fn to_reports(lines: List(String)) -> Result(List(Record), Nil) {
  lines |> list.try_map(split_line) |> result.try(fn(a) { Ok(list.reverse(a)) })
}

fn split_line(l: String) -> Result(Record, Nil) {
  l
  |> string.replace("\n", "")
  |> string.split(" ")
  |> string_list_to_int
}

fn string_list_to_int(l: List(String)) -> Result(Record, Nil) {
  l |> list.try_map(int.base_parse(_, 10))
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
