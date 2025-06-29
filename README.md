# Tastoids

[![Package Version](https://img.shields.io/hexpm/v/tastoid)](https://hex.pm/packages/tast3oid)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tastoid/)


*TODO*

- [ ] Write a bit more of an introduction here.
- [ ] 

## What are Tastoids?

> They're like comparing 'Apples' to 'Oranges'

## Try it out

```sh
gleam add tastoid@1
```

```gleam
import tastoid.{like, dislike, blend, retract}

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
```

Using `gleam run`, you should see the following results:

```bash
$ gleam run 
  Hello, Tastoids!

src/tastoids.gleam:203
Tastoid(Taste("apples", 1.0), 1)
src/tastoids.gleam:205
Tastoid(Taste("oranges", -1.0), 1)

 Blend into ...
src/tastoids.gleam:209
Tastoid(Tastes(dict.from_list([#("apples", 1.0), #("oranges", -1.0)])), 2)

 Squash to an average of ...
src/tastoids.gleam:212
Tastoid(Tastes(dict.from_list([#("apples", 0.5), #("oranges", -0.5)])), 1)


 Blend is also invertible!  Retracting a dislike...
src/tastoids.gleam:215
Tastoid(Taste("oranges", 1.0), -1)
 ... which blends-*out* the original dislike
src/tastoids.gleam:217
Tastoid(Taste("apples", 1.0), 1)


'Blue Blue Brown Blue' |> split(' ') |> map(like) |> reduce(join)
↪ src/tastoids.gleam:228
Ok(Tastoid(Tastes(dict.from_list([#("Blue", 3.0), #("Brown", 1.0)])), 4))
Done
```

Further documentation can be found at <https://hexdocs.pm/tastoid>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```


## License & Terms

Copyright © Avery Quinn 2025

Provided under an AGPL-3.0-only license.  See `LICENSE` for complete terms.
