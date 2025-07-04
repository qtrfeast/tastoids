import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleamy/bench
import tastoids
import tastoids/tastoid

pub fn main() -> Nil {
  bench.run(
    [32, 64, 128, 256, 512, 1024, 2048]
      |> list.map(fn(d) {
        // scale n with d to better observe its performance
        let n = int.divide(4096, d) |> result.unwrap(or: 2)
        let label_n = string.append("n = ", int.to_string(n))
        let label_d =
          string.append("d = ", int.to_string(d)) |> string.append(", ")
        let label = string.append(label_d, label_n)
        bench.Input(label, d)
      }),
    [
      bench.SetupFunction("t ⩐ t (blend)", fn(d) {
        let n = int.divide(4096, d) |> result.unwrap(or: 2)
        let indices = list.range(1, to: d)
        let values = list.repeat(1.0, times: d)
        let t = tastoid.from_sparse_embedding(values, by: indices)
        let ts = list.repeat(t, times: n)
        fn(_d) { list.reduce(ts, tastoids.blend) }
      }),
    ],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99), bench.Mean])
  |> io.println()
}
