import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import iv

type LinesArr =
  iv.Array(iv.Array(String))

pub fn main() -> Result(Nil, Nil) {
  use input <- result.try(parse_input())

  input
  |> get_lines_letters
  |> list.map(iv.from_list)
  |> iv.from_list
  |> count_xmas
  |> echo

  Ok(Nil)
}

fn count_xmas(lines: LinesArr) -> Int {
  lines
  |> iv.index_fold(0, fn(o_acc, line, o_idx) {
    int.add(
      iv.index_fold(line, 0, fn(i_acc, char, i_idx) {
        case char == "X" {
          True -> i_acc + find_xmas(lines, o_idx, i_idx)
          False -> i_acc
        }
      }),
      o_acc,
    )
  })
}

fn find_xmas(lines: LinesArr, xo_idx: Int, xi_idx: Int) -> Int {
  let assert Ok(first) = iv.get(lines, 0)

  let line_length = iv.length(first)
  let lines_length = iv.length(lines)

  find_xmas_hor(lines, xo_idx, xi_idx, line_length)
  + find_xmas_ver(lines, xo_idx, xi_idx, lines_length)
  + find_xmas_diag(lines, xo_idx, xi_idx, lines_length, line_length)
}

fn find_xmas_diag(
  lines: LinesArr,
  xo_idx: Int,
  xi_idx: Int,
  lines_length: Int,
  line_length: Int,
) -> Int {
  let top_right = case lines_length - xo_idx >= 4 && line_length - xi_idx >= 4 {
    True ->
      find_xmas_loop(
        lines,
        fn(away) { xo_idx + away },
        fn(away) { xi_idx + away },
        1,
      )
    False -> 0
  }

  let top_left = case lines_length - xo_idx >= 4 && xi_idx >= 3 {
    True ->
      find_xmas_loop(
        lines,
        fn(away) { xo_idx + away },
        fn(away) { xi_idx - away },
        1,
      )

    False -> 0
  }

  let bottom_right = case xo_idx >= 3 && line_length - xi_idx >= 4 {
    True ->
      find_xmas_loop(
        lines,
        fn(away) { xo_idx - away },
        fn(away) { xi_idx + away },
        1,
      )
    False -> 0
  }

  let bottom_left = case xo_idx >= 3 && xi_idx >= 3 {
    True ->
      find_xmas_loop(
        lines,
        fn(away) { xo_idx - away },
        fn(away) { xi_idx - away },
        1,
      )

    False -> 0
  }

  top_right + top_left + bottom_left + bottom_right
}

fn find_xmas_ver(
  lines: LinesArr,
  xo_idx: Int,
  xi_idx: Int,
  lines_length: Int,
) -> Int {
  let top = case xo_idx >= 3 {
    True ->
      find_xmas_loop(lines, fn(away) { xo_idx - away }, fn(_) { xi_idx }, 1)
    False -> 0
  }

  let bottom = case lines_length - xo_idx >= 4 {
    True ->
      find_xmas_loop(lines, fn(away) { xo_idx + away }, fn(_) { xi_idx }, 1)
    False -> 0
  }

  top + bottom
}

fn find_xmas_hor(
  lines: LinesArr,
  xo_idx: Int,
  xi_idx: Int,
  line_length: Int,
) -> Int {
  let left = case xi_idx >= 3 {
    True ->
      find_xmas_loop(lines, fn(_) { xo_idx }, fn(away) { xi_idx - away }, 1)
    False -> 0
  }

  let right = case line_length - xi_idx >= 4 {
    True ->
      find_xmas_loop(lines, fn(_) { xo_idx }, fn(away) { xi_idx + away }, 1)
    False -> 0
  }

  right + left
}

fn find_xmas_loop(
  lines: LinesArr,
  xo_idx_dir: fn(Int) -> Int,
  xi_idx_dir: fn(Int) -> Int,
  away: Int,
) -> Int {
  case away == 4 {
    True -> 1
    False -> {
      let y_away = xo_idx_dir(away)
      let assert Ok(line) = iv.get(lines, y_away)

      let x_away = xi_idx_dir(away)
      let assert Ok(char) = iv.get(line, x_away)

      case char == get_xmas_by_int(away) {
        True -> find_xmas_loop(lines, xo_idx_dir, xi_idx_dir, away + 1)
        False -> 0
      }
    }
  }
}

fn get_xmas_by_int(c: Int) {
  case c {
    0 -> "X"
    1 -> "M"
    2 -> "A"
    3 -> "S"
    _ -> "X"
  }
}

fn parse_input() -> Result(List(String), Nil) {
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
    Ok(line) ->
      get_lines_loop(stream, [line, ..acc])
      |> result.try(fn(l) { Ok(list.reverse(l)) })
    Error(file_stream_error.Eof) -> Ok(acc)
    Error(_) -> Error(Nil)
  }
}

fn get_lines_letters(lines: List(String)) -> List(List(String)) {
  lines
  |> list.map(fn(v) { string.replace(v, "\n", "") |> string.split("") })
}
