//// Helpful shorthands for quickly making a Tastoid from
//// a like, dislike, 'meh' or pass (zero-ish Tastoid)

import tastoids/tastoid.{
  type Tastoid, Meh, Pass, Saw, Yuck, Yum, from_impression,
}

/// Coerce any `index` into a simple `Tastoid` with a positive sentiment
pub fn like(this thing: String) -> Tastoid(String) {
  from_impression(of: thing, worth: Yum)
}

/// Coerce any `index` into a simple `Tastoid` with a negative sentiment
pub fn dislike(this thing: String) -> Tastoid(String) {
  from_impression(of: thing, worth: Yuck)
}

/// Coerce any `index` into a simple `Tastoid` with a weak negative sentiment.
pub fn meh(this thing: String) -> Tastoid(String) {
  from_impression(of: thing, worth: Meh)
}

/// Coerce any `index` into a simple `Tastoid` with a specific worth
/// (weight coefficient/multiplier for `this`'s value)
pub fn saw(this thing: String, worth weight: Float) -> Tastoid(String) {
  from_impression(of: thing, worth: Saw(weight))
}

/// Coerce any `index` into a simple `Tastoid` with no sentiment or
/// contribution (the empty tastoid/`Insipoid`)
pub fn pass(this thing: String) -> Tastoid(String) {
  from_impression(of: thing, worth: Pass)
}
