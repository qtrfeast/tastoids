//// Helpful shorthands for quickly making a Tastoid from
//// a like, dislike, 'meh' or pass (zero-ish Tastoid)

import tastoids/tastoid.{
  type Tastoid, Meh, Pass, Saw, Yuck, Yum, from_impression,
}

/// Coerce any `index` into a simple `Tastoid` with a positive sentiment
pub fn like(this index: index) -> Tastoid(index) {
  from_impression(of: index, worth: Yum)
}

/// Coerce any `index` into a simple `Tastoid` with a negative sentiment
pub fn dislike(this index: index) -> Tastoid(index) {
  from_impression(of: index, worth: Yuck)
}

/// Coerce any `index` into a simple `Tastoid` with a weak negative sentiment.
pub fn meh(this index: index) -> Tastoid(index) {
  from_impression(of: index, worth: Meh)
}

/// Coerce any `index` into a simple `Tastoid` with a specific worth
/// (weight coefficient/multiplier for `this`'s value)
pub fn saw(this index: index, worth weight: Float) -> Tastoid(index) {
  from_impression(of: index, worth: Saw(weight))
}

/// Coerce any `index` into a simple `Tastoid` with no sentiment or
/// contribution (the empty tastoid/`Insipoid`)
pub fn pass(this index: index) -> Tastoid(index) {
  from_impression(of: index, worth: Pass)
}
