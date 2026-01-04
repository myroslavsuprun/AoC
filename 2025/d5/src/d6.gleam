import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/string

pub fn main() -> Nil {
  parse_input() |> get_lines |> operate |> echo
  Nil
}

type Sign {
  Mult
  Plus
}

type Expr =
  #(Sign, List(Int))

fn operate(l: List(Expr)) -> Int {
  use acc, e <- list.fold(l, 0)

  case e.0 {
    Plus -> int.sum(e.1)
    Mult -> mult(e.1)
  }
  + acc
}

fn mult(i: List(Int)) {
  list.fold(i, 1, fn(acc, i) { i * acc })
}

fn get_lines(i: String) {
  i
  |> split_new_line
  |> list.map(replace_spaces)
  |> list.map(string.split(_, " "))
  |> transpose
  |> list.filter(fn(i) { list.is_empty(i) == False })
  |> list.map(column_to_tuple)
  |> echo
}

fn list_get(lst: List(a), lookup: Int) -> Result(a, Nil) {
  list_get_loop(lst, lookup, 0)
}

fn list_get_loop(lst: List(a), lookup: Int, curr: Int) -> Result(a, Nil) {
  case lst {
    [] -> Error(Nil)
    [i, ..rest] -> {
      case curr == lookup {
        True -> Ok(i)
        False -> list_get_loop(rest, lookup, curr + 1)
      }
    }
  }
}

fn transpose(grid: List(List(a))) -> List(List(a)) {
  case grid {
    [] -> []
    rows -> {
      let heads = list.filter_map(rows, list.first)
      let tails = list.filter_map(rows, list.rest)
      [heads, ..transpose(tails)]
    }
  }
}

fn column_to_tuple(column: List(String)) -> Expr {
  let assert Ok(sign) = list.last(column)
  let sign = parse_sign(sign)
  let numbers_str = list.take(column, list.length(column) - 1)

  let numbers =
    numbers_str
    |> list.map(split_ints_to_nums)
    |> by_column
    |> list.map(parse_int)

  #(sign, numbers)
}

fn split_ints_to_nums(str: String) {
  string.split(str, "")
}

fn by_column(lst: List(List(String))) {
  let assert Ok(first) = list.first(sort_strings_by_len(lst))
  let first_len = list.length(first)

  let lst = ensure_proper_length(lst, first_len) |> list.reverse
  let res =
    list.repeat("", first_len)
    |> list.map_fold(0, fn(acc, _) {
      let nums = get_by_column(lst, acc)

      #(acc + 1, string.join(nums, ""))
    })

  res.1
}

fn ensure_proper_length(items: List(List(String)), len: Int) {
  use i <- list.map(items)

  case list.length(i) == len {
    True -> i
    False -> {
      let additional = list.repeat("", len - list.length(i))
      list.append(additional, i)
    }
  }
}

fn get_by_column(lst: List(List(String)), acc: Int) {
  let init: List(String) = []
  use acc_i, a <- list.fold(lst, init)

  case list_get(a, acc) {
    Error(_) -> acc_i
    Ok(num) ->
      case num == "" {
        False -> [num, ..acc_i]
        True -> acc_i
      }
  }
}

fn sort_strings_by_len(lst: List(List(String))) -> List(List(String)) {
  use a, b <- list.sort(lst)

  int.compare(list.length(b), list.length(a))
}

fn split_new_line(i: String) -> List(String) {
  let split = string.split(i, "\n")

  list.take(split, list.length(split) - 1)
}

fn replace_spaces(l: String) -> String {
  l
  |> string.split(" ")
  |> list.filter(fn(s) { s != "" })
  |> string.join(" ")
}

fn parse_int(char: String) -> Int {
  let assert Ok(int) = int.base_parse(char, 10)
  int
}

fn parse_sign(char: String) -> Sign {
  case char {
    "*" -> Mult
    "+" -> Plus
    other -> {
      echo other
      panic as "i didn't know you were here"
    }
  }
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
