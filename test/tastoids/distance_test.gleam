import playground/distance.{Length, length}
import tastoids.{blend}
import tastoids/from.{like, saw}

pub fn less_tess() {
  todo
}

pub fn length_test() {
  let one = "cats" |> saw(worth: 1.25)
  let Length(l, k) = length(of: one)
  assert l == 1.25
  assert k == 1
}

pub fn distance_test() {
  let cats = "cats" |> like
  let dogs = "dogs" |> like
  let mostly_cats = cats |> blend(cats) |> blend(cats) |> blend(dogs)
  let even_split = cats |> blend(cats) |> blend(dogs) |> blend(dogs)

  let delta = tastoids.less(even_split, from: mostly_cats) |> echo
  let Length(l, k) = length(of: delta) |> echo
  assert l == 2.0
  assert k == 0
}
