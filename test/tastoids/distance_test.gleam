import tastoids.{blend, distance}
import tastoids/from.{like, saw}

// pub fn less_tess() {
//  todo
// }

pub fn length_test() {
  let one = "cats" |> saw(worth: 1.25)
  assert distance(covered_by: one) == 1.25
}

pub fn distance_test() {
  let cats = "cats" |> like
  let dogs = "dogs" |> like
  let mostly_cats = cats |> blend(cats) |> blend(cats) |> blend(dogs)
  let even_split = cats |> blend(cats) |> blend(dogs) |> blend(dogs)

  let delta = tastoids.less(even_split, from: mostly_cats)
  assert distance(covered_by: delta) == 2.0
}
