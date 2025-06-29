//// Tastoids (& their 'Temperate' Algebra)
////
////  "Taste", broadly, is a 'sentiment' about a unique thing.  
////
//// It is often said, one can't compare "apples" to "oranges",
//// but I daresay.. perhaps you can?  Let me show you how.
////
//// An indexable sentiment (or lack thereof), able to participate in
//// the Tastoid algebraic operations
//// 
//// Given, the set of all Vectors are a field ℝⁿ (aka 𝕍),
//// 
//// AND  i  is an enumerable set of indices (ⅈ <= countable ∞) 
////                  (loosely, a 'taste' field)
////
//// Then,  𝛂aᵢ ∈ 𝔸  are the set of all 'unit' `tastes` (scaled by 𝛂)
////
////   ** Try to guess what happens if your imbedding is 'flat',
////      mapping 'a' word directly to itself with value 1?
////
//// If,   we partition a taste-field further, by a (complex) cardinality  k ∈ 𝕂 (𝕂 ~ ℝ x ℝ₄ ~ ℂ)
////  AND   a _tasting_ of some 'i' (by subject 'u') with weight (𝛂) and count (k)
////        'Imbed' an individual's sentiment as a 'Tastoid'   𝕥ᵤ↪ᵢ ∈ 𝕋
////
////   i.e.  someone (or thing) expressing       {    by like ( 1+i )   ->  dislike (-1 + i)
////     𝕒 taste (valued at weight 𝛂), k times     -> un-like (-1 + -i) -> un-dislike (1 + -i) } 
////
////
////  Then, we may define a handful a tiny, tidy, yet supremely powerful (σ/sigma-)
////    _Algebra_ of Taste_
//// 
////  (A thorough reckoning of its axioms will take time, learning, and discourse with others;
////   suffice to say I mean a formal category-theory 'Algebra' with several handy properties,
////   notably invertible, self-integrating distillation of an 'average' taste!)
////   
////   - add(t¹, u¹) -> (t + u)¹       ('regular' properties of scalar vector addition)
////   - scale(tⁿ, k)   -> tⁿᵏ         ('regular' properties of scalar vector multiplication)
////   - blend(t¹, u¹))  ->  (t + u)²  ('tensor' product;  associative, distributive, commutative, invertable)
////       (equiv. to)  ~> (½t + ½u)¹
////   - squash(tᵏ, p)  ->   ||t||ₚ   ( for p =0, yields the unipotent norm--i.e. every sparse tᵢ -> 1
////                                        p==1, yields the normal tastoid (weighted power mean)
////                                        p!=0, yields the p-norm of t with k=p )

// AND  𝔸  is a bijective imbedding of 'a' subject into 𝕍/ⅈ

import gleam/float
import gleam/int
import gleam/list
import gleam/set.{type Set}

import internal/taste.{type Taste, add, negate, scale}

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

/// An Index(space) is any set of values ⅈ (<= countable ∞),
/// such as:
///
///   - An index `i` within a countable set , e.g. the integers (ℤ),
///     strings, _any set with a semblance of equality/comparability_.
///   - An embedding model's range of possible values from 'thing' to index.
///     (see `Embedding(indexable)`)
///   - A set of indices within that `Index(space)`
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

/// A `Tastoid(t)` (𝕥) is a subset of Tastoids (𝕋)
/// constrained to the same _imbedding_ `Index(space)` (𝕚).
pub opaque type Tastoid(t) {
  /// A cutesy name for the empty set (shared regardless of index-space)
  Insipoid
  // EmptyTastoid(taste: Taste(index))
  /// An impression (or aggregation) of taste
  /// e.g. Tastoid(t) -> Tastoids(t, 1)
  Tastoid(taste: Taste(t), cardinality: Int)
}

/// The empty `Tastoid`
pub const null = Insipoid

/// Coerce a `thing` of an into a `Tastoid`
pub fn from(thing index: Index(space)) -> Tastoid(Index(space)) {
  taste.from_sentiment(1.0, of: index) |> Tastoid(1)
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

/// Given a Taste and (scaling) impression, yield a Tastoid with
/// a singular contribution (k=1)
pub fn from_tasting(
  of taste: Taste(index),
  thought impression: Impression,
) -> Tastoid(index) {
  case impression {
    Yum -> taste |> Tastoid(1)
    Yuck -> taste |> negate |> Tastoid(1)
    Meh -> taste |> scale(by: -0.05) |> Tastoid(1)
    Saw(worth) -> taste |> scale(by: worth) |> Tastoid(1)
    Pass -> Insipoid
  }
}

/// Given any index (`string`, `Int`, or `Set(index)``), coerce it into
/// a simple Tastoid worth a single contribution (k=1)
pub fn from_impression(
  of index: index,
  thought sentiment: Impression,
) -> Tastoid(index) {
  taste.from_sentiment(1.0, of: index) |> from_tasting(thought: sentiment)
}

/// Coerce a sparse/dense embeddings pair of value and index lists
/// into a conjugated Tastoid worth a single contribution (k=1)
pub fn from_sparse_embedding(
  values: List(Float),
  by indices: List(index),
  thought sentiment: Impression,
) -> Tastoid(index) {
  list.zip(indices, values)
  |> taste.from_tuples
  |> from_tasting(thought: sentiment)
}

/// Coerce any `index` value into a simple `Tastoid` with sentiment 1.0
pub fn like(this index: index) -> Tastoid(index) {
  from_impression(of: index, thought: Yum)
}

/// Coerce any `index` value into a simple `Tastoid` with sentiment -1.0
pub fn dislike(this index: index) -> Tastoid(index) {
  from_impression(of: index, thought: Yuck)
}

/// Coerce any `index` value into a simple `Tastoid` with sentiment -0.05 >
pub fn meh(this index: index) -> Tastoid(index) {
  from_impression(of: index, thought: Meh)
}

/// Coerce any `index` value into a simple `Tastoid` with no sentiment or
/// contribution (the empty tastoid/`Insipoid`)
pub fn pass(this index: index) -> Tastoid(index) {
  from_impression(of: index, thought: Pass)
}

/// Blend the two tastoids, producing a larger tastoid  congruent to
/// the weighted power mean, aka their average (via `squash`)
///
/// See also `inverse` - which yields u' which _unblends_ when blended,
pub fn blend(t: Tastoid(index), with u: Tastoid(index)) {
  case t, u {
    Insipoid, _ -> u
    _, Insipoid -> t
    Tastoid(t, k_t), Tastoid(u, k_u) -> add(t, u) |> Tastoid(int.add(k_t, k_u))
  }
}

/// A feature of this algebra is every element has an inverse over join
pub fn inverse(of taste: Tastoid(index)) -> Tastoid(index) {
  case taste {
    Tastoid(t, k) -> negate(t) |> Tastoid(int.negate(k))
    Insipoid -> Insipoid
  }
}

/// Alias of `inverse`. Returns a Tastoid that will 'undo' the initial t over `join`
pub const retract = inverse

/// Reduce k -> 1, yielding the 'average'/normalized tastoid (of all enjoined Tastoids)
pub fn squash(tastoid: Tastoid(index)) {
  case tastoid {
    // Squashing a k=1 tastoid is the base case, so it returns unchanged.
    Tastoid(_, 1) as t -> t
    // A 0-strength taste squashes towards the emptiest taste (Null)
    Tastoid(_, 0) -> Insipoid
    // When k is non-zero, return the de-weighted norm of t (scale by 1 over k)
    Tastoid(t, k) -> {
      // A special coefficient that grounds t into k=1 when applied via scalar multiplication
      let try_divide = float.divide(1.0, int.to_float(k))
      case try_divide {
        Ok(one_over_k) -> scale(t, by: one_over_k) |> Tastoid(1)
        Error(_) -> Insipoid
      }
    }
    Insipoid -> Insipoid
  }
}

/// Combine two tastoids _hard_, blending them and returing their squashed mean.
pub fn smash(t: Tastoid(index), with u: Tastoid(index)) -> Tastoid(index) {
  blend(t, u) |> squash
}

/// Returns True iff the Tastoids t & u are congruent (weakly equivalent)
///
/// *Example*
///
///  "cat" |> like
pub fn equivalent(t: Tastoid(index), u: Tastoid(index)) -> Bool {
  case t, u {
    Insipoid, Insipoid -> True
    _, Insipoid -> False
    Insipoid, _ -> False
    Tastoid(t, k_t), Tastoid(u, k_u) if k_t == k_u -> {
      t == u
    }
    t, u -> equivalent(squash(t), squash(u))
  }
}
