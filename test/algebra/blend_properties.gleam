import gleeunit/should
import tastoids.{blend, dislike, like, null, retract}

pub fn is_associative_test() {
  let a = like("cats")
  let b = dislike("cats")
  let c = like("dogs")

  let ab_c = a |> blend(b) |> blend(c)
  let a_bc = b |> blend(c) |> blend(a)

  should.equal(ab_c, a_bc)
}

pub fn has_identity_test() {
  let e = null
  let a = like("bread")

  let ea = blend(e, a)
  let ae = blend(a, e)

  should.equal(ea, ae)
}

pub fn has_inverse_test() {
  let like_something = like("something")
  let like_cats = like("cats")
  let unlike_cats = "cats" |> like |> retract

  like_something
  |> blend(like_cats)
  |> blend(unlike_cats)
  |> should.equal(like_something)
}

pub fn is_commutative_test() {
  let liked = "cats" |> like
  let unliked = "cats" |> like |> retract

  let like_unlike = blend(liked, unliked)
  let unlike_like = blend(unliked, liked)
  like_unlike |> should.equal(unlike_like)
}
