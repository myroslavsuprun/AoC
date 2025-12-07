import file_streams/file_stream
import file_streams/file_stream_error
import gleam/int
import gleam/list
import gleam/pair
import gleam/string

pub fn main() -> Nil {
  parse_input()
  |> split_actions()
  |> do_actions(50)
  |> echo

  Nil
}

fn do_actions(actions: List(Action), init: Int) -> Int {
  let total_occurrences = 0
  let result =
    actions
    |> list.fold(#(init, total_occurrences), fn(acc, el) {
      let curr = pair.first(acc)
      let zero_count = pair.second(acc)

      echo #(curr, el) as "curr, el"
      let new_curr = case pair.first(el) {
        Minus -> curr - pair.second(el)
        Plus -> curr + pair.second(el)
      }

      let zero_count =
        case pair.first(el) {
          Plus -> new_curr / 100
          Minus ->
            case curr == 0 {
              True -> pair.second(el) / 100
              False ->
                case pair.second(el) >= curr {
                  True -> { pair.second(el) - curr } / 100 + 1
                  False -> 0
                }
            }
        }
        + zero_count

      let curr = case new_curr > 99 {
        True -> new_curr % 100
        False ->
          case new_curr < 0 {
            True -> { new_curr % 100 + 100 } % 100
            False -> new_curr
          }
      }

      // let total = case curr == 0 {
      //   True -> {
      //     echo #(curr, total + 1) as "total increase"
      //     total + 1
      //   }
      //   False -> total
      // }

      #(curr, zero_count)
    })

  pair.second(result)
}

type PlusMinus {
  Minus
  Plus
}

type Action =
  #(PlusMinus, Int)

fn split_actions(lines: String) -> List(Action) {
  let lines_list = lines |> string.split("\n")

  list.take(lines_list, list.length(lines_list) - 1) |> list.map(line_to_action)
}

fn line_to_action(line: String) -> Action {
  let assert Ok(letter) = string.first(line) as "should have valid letter"
  let assert Ok(jump) = string.drop_start(line, 1) |> int.base_parse(10)
    as "should parse a valid jump"

  case letter {
    "L" -> #(Minus, jump)
    "R" -> #(Plus, jump)
    _ -> panic as "invalid letter (neither L nor R)"
  }
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
