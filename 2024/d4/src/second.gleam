import gleam/int
import gleam/io
import iv

// bubble sort, in my gleam?
pub fn exec() {
  // make an array of 10 random integers
  let array = iv.initialise(10, fn(_) { int.random(100) })
  let sorted = bubble_sort(array)

  use item <- iv.each(sorted)

  io.println(int.to_string(item))
}

fn bubble_sort(array) {
  bubble_sort_loop(array, 1, iv.length(array))
}

fn bubble_sort_loop(array, index, max_index) {
  case iv.get(array, index - 1), iv.get(array, index) {
    // found 2 elements in the wrong order, swap them, then continue
    Ok(prev), Ok(curr) if prev > curr -> {
      let array =
        array
        |> iv.try_set(index, prev)
        |> iv.try_set(index - 1, curr)
      bubble_sort_loop(array, index + 1, max_index)
    }

    // found 2 elements in the correct order, we can skip them!
    Ok(_), Ok(_) if index < max_index ->
      bubble_sort_loop(array, index + 1, max_index)

    // reached the end, decrease max_index then try again!
    _, _ if max_index > 2 -> bubble_sort_loop(array, 1, max_index - 1)

    // reached the end and no more elements to swap, we are done.
    _, _ -> array
  }
}
