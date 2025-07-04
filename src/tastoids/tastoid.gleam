import gleam/list
import tastoids/imbedding.{type Imbedding}
import tastoids/taste.{type Taste, negate, scale}

/// A `Tastoid` (𝕥) is an element within a subset of Tastoids (𝕋),
/// constrained to only interact with other tastoids  `of` the same
/// _imbedding indices_ ( `Imbedding(space)`).
pub type Tastoid(of) {
  /// The empty Tastoid (shared by all index-spaces)
  Tasteless
  // EmptyTastoid(taste: Taste(index))
  /// An impression (or aggregation) of taste
  /// e.g. Tastoid(t) -> Tastoids(t, 1)
  Tastoid(taste: Taste(of), cardinality: Int)
}

/// Coerce a `thing` of an into a `Tastoid`, assuming...
///
/// - The `thing`'s type is the `Imbedding(space)` of the `Tastoid`
/// - The sentiment of that thing is `1.0` ~ a count of its occurances
///
/// In effect, `from(thing)` is `1` of that thing, as a `Tastoid`
/// 
/// ## Example:
///
///     "from" |> tastoid.from -> Tastoid(Taste("from", 1.0"), k=1) 
///     42     |> tastoid.from -> Tastoid(Taste(42, 1.0), k=1)
pub fn from(thing index: Imbedding(space)) -> Tastoid(Imbedding(space)) {
  taste.from_one(of: index) |> Tastoid(1)
}

pub type Impression {
  /// I liked it, +1
  Yum
  /// I disliked it, -1
  Yuck
  /// I saw it, and ignoring it is worth ~ -5%
  Meh
  /// I saw it, ascribing scaling it by weight
  Saw(worth: Float)
  /// I saw it, and have absolutely no impression
  Pass
}

/// A _tasting_ of a taste and the impression thereof (e.g. a 'weight'
/// or _value-multiplier_) yield a Tastoid of cardinality (k=1).
pub fn from_taste(
  of taste: Taste(index),
  worth impression: Impression,
) -> Tastoid(index) {
  case impression {
    Yum -> taste |> Tastoid(1)
    Yuck -> taste |> negate |> Tastoid(1)
    Meh -> taste |> scale(by: -0.05) |> Tastoid(1)
    Saw(worth) -> taste |> scale(by: worth) |> Tastoid(1)
    Pass -> Tasteless
  }
}

/// Given any index (`string`, `Int`, or `Set(index)``), coerce it into
/// a simple Tastoid worth a single contribution (k=1)
pub fn from_impression(
  of index: index,
  worth sentiment: Impression,
) -> Tastoid(index) {
  taste.from_one(of: index) |> from_taste(worth: sentiment)
}

/// Coerce a sparse/dense embeddings pair of value and index lists
/// into a conjugated Tastoid worth a single contribution (k=1)
pub fn from_sparse_embedding(
  values: List(Float),
  by indices: List(index),
) -> Tastoid(index) {
  list.zip(indices, values)
  |> taste.from_tuples
  |> from_taste(worth: Yum)
}
