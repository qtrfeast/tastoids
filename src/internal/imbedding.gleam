//// An Index(space) is any set of values ⅈ (<= countable ∞),
//// able to map a 'thing' to its imbedded index (imbex):
////
////   - An index `i` within a countable set , e.g. the integers (ℤ),
////     strings, _any set with a semblance of equality/comparability_.
////   - An embedding model's range of possible values from 'thing' to index.
////     (see `Embedding(indexable)`)
////   - A set of indices within that `Index(space)`

import gleam/set.{type Set}

/// An Embedding is a bijective map of some indexable element
/// mapped to the index it corresponds to (its _imbex_)
pub type EmbeddingTo(imbex) {
  EmbeddingString(fn(String) -> imbex)
}

/// The _identity_ embedding of strings, mapping each string to itself.
pub type EmbeddingStringIdentity =
  EmbeddingTo(String)

/// Any embedding of a string to a consistent integer value.
pub type EmbeddingStringToInt =
  EmbeddingTo(Int)

/// An `Index(space)` is a set of index values (imbex,pl: imbices)
/// shared by a category of `Tastoids`.
pub type Index(space) {
  Index(space)
  Imbex(embedding: EmbeddingTo(space))
  Indices(Set(Index(space)))
}

/// An _identity_ `Index` for strings, mapping a string `s` to itself.
///
///  e.g...
///
///     "gleam" ↪ Index("gleam") ∈ Index(String)
pub type ByString =
  Index(EmbeddingStringIdentity)
