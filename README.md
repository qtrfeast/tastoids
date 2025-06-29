# Tastoids ⩐

[![Package Version](https://img.shields.io/hexpm/v/tastoid)](https://hex.pm/packages/tastoids)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tastoids/)

A _Temperate_, Terse ***Algebra of Taste***


## Wait, _What_?

> Tastoids & their Algebra... are like comparing 'Apples' to 'Oranges'

- [ ] Write a bit more of an introduction here.

## Give them a Taste

```sh
gleam add tastoids
```

```gleam
import gleam/io
import tastoids.{like} as t

pub fn main() -> Nil {
  io.println("Hello, Tastoids!\n")

  let apples = like("apples") |> echo
  // ↪ Tastoid(Taste("apples", 1.0), 1)

  let oranges = like("oranges") |> echo
  //  ↪ Tastoid(Taste("oranges", 1.0), 1)

  io.println("\n Blend into ...")
  let tastes = t.blend(apples, oranges) |> echo
  //  ↪ Tastoid(Taste(... [#("apples", 1.0), #("oranges", -1.0)])), 2)

  io.println("\n Squash to an average of ...")
  t.squash(tastes) |> echo
  //   ↪ Tastoid(Tastes(dict.from_list([#("apples", 0.5), #("oranges", -0.5)])), 1)


  io.println("\n Blend is also invertible!  blend(blended, retract(oranges)) -> like(apples)!")
  t.blend(tastes, t.retract(oranges)) |> echo
  //   ↪ Tastoid(Taste("apples", 1.0), 1)

  io.println(
    "\n\n'Blue Blue Brown Blue' |> split(' ') |> map(like) |> reduce(t.blend) ",
  )
  io.print("↪ ")
  let _ =
    "Blue Blue Brown Blue"
    |> string.split(" ")
    |> list.map(fn(word) { like(word) })
    |> list.reduce(t.blend)
    |> echo

  io.println("\n Have fun!")
}
```

Further documentation can be found at <https://hexdocs.pm/tastoids>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## License & Terms

Copyright © Avery Quinn 2025

Provided under an AGPL-3.0-only license.  See `LICENSE` for complete terms.
