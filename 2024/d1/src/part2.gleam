import gleam/pair
import gleam/result
import part1

pub fn exec_part2() -> Result(Int, Nil) {
  use lists <- result.try(part1.parse_input())
  let location_lists = part1.get_sorted_ints(lists)

  Ok(count_occurrences(pair.first(location_lists), pair.second(location_lists)))
}

fn count_occurrences(left: List(Int), right: List(Int)) -> Int {
  count_occurrences_loop(left, right, 0)
}

fn count_occurrences_loop(left: List(Int), right: List(Int), acc: Int) -> Int {
  case left {
    [for, ..rest] -> {
      let occurrences = count_left_inner(for, right, 0)
      count_occurrences_loop(rest, right, acc + for * occurrences)
    }
    [] -> acc
  }
}

fn count_left_inner(for: Int, right: List(Int), acc: Int) -> Int {
  case right {
    [v, ..rest] -> {
      case v == for {
        True -> count_left_inner(for, rest, acc + 1)
        False -> count_left_inner(for, rest, acc)
      }
    }
    [] -> acc
  }
}
