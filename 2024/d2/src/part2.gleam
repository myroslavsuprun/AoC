import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import part1

type Record =
  List(Int)

type Dir {
  Up
  Down
}

pub fn exec_part2() -> Nil {
  let _ =
    part1.parse_input()
    |> result.try(to_reports)
    |> result.map(get_safe_records)
  Nil
}

fn get_safe_records(levels: List(Record)) -> Result(Int, Nil) {
  let counter =
    levels
    |> list.count(is_safe_record)
    |> echo

  Ok(counter)
}

fn is_safe_record(r: Record) -> Bool {
  print_list(r)
  echo is_safe_record_loop(r, None, None, True)
    || is_safe_record_loop(list.reverse(r), None, None, True)
    as "result"
}

fn print_list(r: Record) -> Nil {
  let result =
    r
    |> list.map(int.to_string)
    |> string.join(" ")

  io.println("record: " <> result)
}

fn is_safe_record_loop(l, prev, dir, can_skip) -> Bool {
  case l {
    [] -> {
      case !can_skip {
        True -> echo "no skip is left"
        False -> ""
      }
      True
    }
    [c, ..rest] -> {
      is_safe_check_prev(rest, prev, c, dir, can_skip)
    }
  }
}

fn is_safe_check_prev(rest, prev, curr, dir, can_skip) -> Bool {
  case prev {
    Some(prev) -> is_safe_some_prev(rest, prev, curr, dir, can_skip)
    None -> is_safe_record_loop(rest, Some(curr), None, can_skip)
  }
}

fn is_safe_some_prev(rest, prev, curr, dir, can_skip) -> Bool {
  let is_safe = is_safe_level_change(prev, curr, dir)
  case is_safe {
    True -> {
      is_safe_record_loop(
        rest,
        Some(curr),
        option.or(dir, Some(get_dir(prev, curr))),
        can_skip,
      )
    }
    False if can_skip -> {
      echo can_skip as "can_skip"
      is_safe_record_loop(
        rest,
        Some(prev),
        option.or(dir, Some(get_dir(prev, curr))),
        False,
      )
    }
    False -> {
      case can_skip {
        False -> echo "skip no left"
        True -> ""
      }
      False
    }
  }
}

fn is_safe_level_change(prev: Int, curr: Int, dir: Option(Dir)) -> Bool {
  let level_jump = echo int.absolute_value(prev - curr) as "level_jump"

  level_jump <= 3 && level_jump > 0 && matches_dir(dir, prev, curr)
}

fn matches_dir(dir: Option(Dir), a, b) -> Bool {
  let res = case dir {
    Some(d) if a - b >= 0 -> d == Down
    Some(d) -> d == Up
    None -> True
  }

  echo #(res, dir, a, b) as "matches_dir"

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
