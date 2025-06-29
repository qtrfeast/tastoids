//// An Index(space) (or '_Imbedding_') is a set of values ⅈ
//// (<= countable ∞) able to map (_embeds_) a 'thing' to its
//// imbedded-index ('imbex').
////
////   - An index `i` within a countable set , e.g. the integers (ℤ),
////     strings, _any set with a semblance of equality/comparability_.
////   - An embedding model and its range of possible values from a
////     'thing' to index.
////   - A set of indices within that `Index(space)` (untested)

import gleam/set.{type Set}

/// An `Imbedding(space)` is a set of index values (imbex,pl: imbices)
/// shared by a category of `Tastoids`.
pub type Imbedding(space) {
  Index(space)
  Imbex(embedding: EmbeddingTo(space))
  Indices(Set(Imbedding(space)))
}

/// A consistent injection/mapping of a value into a set imbices.
pub type EmbeddingTo(imbex) {
  /// The value being imbeded _is_ the index (String, Int, ...)
  Identity(fn(imbex) -> imbex)
  /// The Imbedding is an _Embedding_ (model), with consistent
  /// but possibly opaque imbices being returned.
  Embedding(model: String, embed: fn(String) -> imbex)
  /// IFF, there is a definable mapping of indices between two systems,
  /// one could prepare a higher-order embedding of embeddings to remap
  /// between differing systems. (Notwithstanding the values would probably
  /// need to be similarly scaled)
  Translating(from: EmbeddingTo(imbex), into: EmbeddingTo(imbex))
}
