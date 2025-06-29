import gleam/io
import gleam/list
import gleam/string
import tastoids.{blend, dislike, like, retract, squash}

pub fn main() -> Nil {
  io.println("Hello, Tastoids!\n")

  let like_apples = like("apples") |> echo
  // ↪ Tastoid(Taste("cats", 1.0), 1)
  let dislike_oranges = dislike("oranges") |> echo
  //  ↪ Tastoid(Taste("cats", 1.0), 1)

  io.println("\n Blend into ...")
  let tastes = blend(like_apples, dislike_oranges) |> echo

  io.println("\n Squash to an average of ...")
  squash(tastes) |> echo

  io.println("\n\n Blend is also invertible!  Retracting a dislike...")
  let undo_dislike = dislike_oranges |> retract |> echo
  io.println(" ... which blends-*out* the original dislike")
  blend(tastes, undo_dislike) |> echo

  io.println(
    "\n\n'Blue Blue Brown Blue' |> split(' ') |> map(like) |> reduce(join) ",
  )
  io.print("↪ ")
  let _ =
    "Blue Blue Brown Blue"
    |> string.split(" ")
    |> list.map(fn(word) { like(word) })
    |> list.reduce(blend)
    |> echo

  io.println("Done")
}
