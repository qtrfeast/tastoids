import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleamy/bench
import playground/fruit
import tastoids
import tastoids/compare
import tastoids/tastoid.{Tasteless}

pub fn main() -> Nil {
  bench.run(
    [2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233]
      |> list.map(fn(n) {
        let label = string.append(int.to_string(n), " pieces of fruit")
        bench.Input(label, n)
      }),
    [
      bench.SetupFunction("|> reduce(blend)", fn(n) {
        let fruits = fruit.sample(n)
        io.println("Blending fruits...")

        let _ = fruits |> echo
        let _ = fruits |> list.length |> echo

        let fruitoids = fruits |> list.map(fruit.to_fruitoid)
        fn(_d) { list.fold(fruitoids, Tasteless, tastoids.blend) }
      }),
      bench.SetupFunction("|> ordering(by: norm)", fn(n) {
        let tasty_fruit = fruit.sample(n)
        io.println("Taste for...")
        let _ = tasty_fruit |> echo
        let tastes =
          tasty_fruit
          |> list.map(fruit.to_fruitoid)
          |> list.fold(Tasteless, tastoids.blend)
        let taste = tastes |> tastoids.squash
        let by_taste = compare.ordering(by: taste)
        fn(_d) {
          fruit.fruit_names
          |> list.sort(by: fn(fruit_a, fruit_b) {
            let a = fruit.to_fruitoid(fruit_a)
            let b = fruit.to_fruitoid(fruit_b)

            by_taste(a, b)
          })
          taste
        }
      }),
    ],
    [bench.Duration(3000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.Max, bench.Mean, bench.SD])
  |> io.println()
}
