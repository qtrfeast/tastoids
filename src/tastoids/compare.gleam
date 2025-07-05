//// Given any `Tastoid` is differentiable with respect to its
//// `distance` to another, (_either `total` and `partial`),
//// it can then be said to impose a _total (partial) ordering_
//// of any other set of Tastoids.
//// 
//// Akin to `gleam/order`, a `Tastoid` *is* its own ordering

import gleam/float
import gleam/order.{type Order}
import tastoids
import tastoids/tastoid.{type Tastoid}

type Compares(space) =
  fn(Tastoid(space), Tastoid(space)) -> Order

/// Return a `compare` which orders elements by the provided `differentiator`
pub fn ordering(by differentiator: Tastoid(space)) -> Compares(space) {
  fn(a: Tastoid(space), b: Tastoid(space)) -> Order {
    let delta_a = tastoids.less(differentiator, from: a) |> tastoids.distance
    let delta_b = tastoids.less(differentiator, from: b) |> tastoids.distance
    float.compare(delta_a, delta_b)
  }
}
