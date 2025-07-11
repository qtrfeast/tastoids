# Tastoids ⩐

[![Package Version](https://img.shields.io/hexpm/v/tastoid)](https://hex.pm/packages/tastoids)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tastoids/)

A _Temperate_, Terse ***Algebra of Taste***

## Wait, _What_?

> Tastoids & their Algebra... are like comparing 'Apples' to 'Oranges'

See [Intro à la Tufte](http://tastoidea.qtr.fea.st/) for a _colouful_ introduction.

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

### Benchmark

While not my priority, it will be helpful to see how differeing implementations
change performance (and its characteristics). To run the benchmarks, use the command:

`gleam run -m bench`

```bash
 $ gleam run -m bench
   Compiling tastoids
    Compiled in 0.20s
     Running bench.main
 benching set d = 32, n = 128 t ⩐ t (blend)
 benching set d = 64, n = 64 t ⩐ t (blend)
 benching set d = 128, n = 32 t ⩐ t (blend)
 benching set d = 256, n = 16 t ⩐ t (blend)
 benching set d = 512, n = 8 t ⩐ t (blend)
 benching set d = 1024, n = 4 t ⩐ t (blend)
 benching set d = 2048, n = 2 t ⩐ t (blend)
 Input               Function                       IPS           Min           P99          Mean
 d = 32, n = 128     t ⩐ t (blend)            2633.7598        0.3593        0.4654        0.3796
 d = 64, n = 64      t ⩐ t (blend)            1336.3796        0.7347        0.7661        0.7482
 d = 128, n = 32     t ⩐ t (blend)            1312.5482        0.7474        0.7781        0.7618
 d = 256, n = 16     t ⩐ t (blend)            1252.1695        0.7757        0.8384        0.7986
 d = 512, n = 8      t ⩐ t (blend)            1114.2264        0.8539        1.2794        0.8974
 d = 1024, n = 4     t ⩐ t (blend)            1177.7919        0.8013        1.3194        0.8490
 d = 2048, n = 2     t ⩐ t (blend)            1511.6774        0.5881        1.1395        0.6615
```

### TODO

- [X] Write a euclidian and cosine distance fn.
  - _See `tastoids/{length,distance}`, `tastoids.taste.{length,condense}`
- [ ] Demonstrate how Tastoids + a vector db and iterative voting
      yield a form of simulated annealing towards the 'true' sentiment
      I was trying to express by voting things up/down.


## As a Matter of Taste

TBD, general motivation, goals, and why this library _will_ be *unabashedly **strange*** 

## License & Terms

Copyright © Avery Quinn 2025

Provided under an AGPL-3.0-only license.  See `LICENSE` for complete terms.
