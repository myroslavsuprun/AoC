import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import iv.{type Array}

pub fn main() -> Nil {
  parse_input()
  |> split_to_lines
  |> convert_to_array
  |> count_accessible
  |> echo

  Nil
}

const directions = [
  #(-1, -1),
  #(-1, 0),
  #(-1, 1),
  #(0, -1),
  #(0, 1),
  #(1, -1),
  #(1, 0),
  #(1, 1),
]

fn count_accessible(i: Grid) -> Int {
  count_accessible_loop(i, 0)
}

fn count_accessible_loop(i: Grid, total: Int) -> Int {
  let result =
    i
    |> iv.index_fold(#(0, i), fn(o_acc, line, y) {
      let o_acc_total = pair.first(o_acc)
      let o_acc_grid = pair.second(o_acc)
      let line_result =
        line
        |> iv.index_fold(#(0, grid_get_line(i, y)), fn(acc, item, x) {
          let is_accessible = check_is_accessible(i, item, #(x, y))

          let acc_total = pair.first(acc)
          let acc_grid = pair.second(acc)
          let new_line_grid = case is_accessible == 1 {
            True -> line_set_item(acc_grid, x, 0)
            False -> acc_grid
          }

          #(acc_total + is_accessible, new_line_grid)
        })

      #(
        pair.first(line_result) + o_acc_total,
        grid_set_line(o_acc_grid, y, pair.second(line_result)),
      )
    })

  case pair.first(result) > 0 {
    True ->
      count_accessible_loop(pair.second(result), total + pair.first(result))
    False -> total
  }
}

fn grid_set_line(grid: Grid, x: Int, line: Array(Int)) -> Grid {
  let assert Ok(ok) = iv.set(grid, x, line)

  ok
}

fn line_set_item(line: Array(Int), y: Int, value: Int) -> Array(Int) {
  let assert Ok(ok) = iv.set(line, y, value)

  ok
}

fn grid_get_line(i: Grid, x: Int) -> Array(Int) {
  let assert Ok(ok) = iv.get(i, x)

  ok
}

type Grid =
  Array(Array(Int))

type XY =
  #(Int, Int)

fn check_is_accessible(i: Grid, item: Int, xy: XY) -> Int {
  case item != 0 {
    True -> {
      case sum_directions(i, xy) < 4 {
        True -> 1
        False -> 0
      }
    }
    False -> 0
  }
}

fn sum_directions(i: Grid, xy: XY) -> Int {
  directions
  |> list.fold(0, fn(acc, dir) {
    let move_x = pair.first(dir)
    let move_y = pair.second(dir)

    let x = pair.first(xy)
    let y = pair.second(xy)

    let x_grid_length =
      iv.length({
        let assert Ok(first) = iv.first(i)
        first
      })
    let y_grid_length = iv.length(i)

    let changed_x = move_x + x
    let changed_y = move_y + y

    let increment = {
      case
        changed_x < 0
        || changed_x >= x_grid_length
        || changed_y < 0
        || changed_y >= y_grid_length
      {
        True -> 0
        False -> {
          get_item_from_grid(i, #(changed_x, changed_y))
        }
      }
    }

    acc + increment
  })
}

fn get_item_from_grid(i: Grid, xy: XY) -> Int {
  let assert Ok(ok) =
    iv.get(
      {
        let assert Ok(y_array) = iv.get(i, pair.second(xy))
        y_array
      },
      pair.first(xy),
    )

  ok
}

fn convert_to_array(li: List(List(Int))) -> Grid {
  li |> list.map(iv.from_list) |> iv.from_list()
}

fn split_to_lines(i: String) -> List(List(Int)) {
  let lines = i |> string.split("\n")
  lines
  |> list.take(list.length(lines) - 1)
  |> list.map(fn(items) { items |> string.split("") |> list.map(symbol_to_int) })
}

fn symbol_to_int(char: String) -> Int {
  let assert Ok(ok) = {
    char
    |> string.replace("@", "1")
    |> string.replace(".", "0")
    |> int.base_parse(10)
  }

  ok
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
