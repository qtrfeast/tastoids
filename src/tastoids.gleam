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
import internal/imbedding
import internal/taste.{type Taste, add, negate, scale}

/// An `Imbedding(space)` is a set of index values (imbex,pl: imbices)
/// shared by a category of `Tastoids`.
pub type Imbedding(space) =
  imbedding.Index(space)

/// A `Tastoid` (𝕥) is an element within a subset of Tastoids (𝕋),
/// constrained to only interact with other tastoids  `of` the same
/// _imbedding indices_ ( `Imbedding(space)`).
pub opaque type Tastoid(of) {
  /// A (cutesy) name for the empty Tastoid (shared by all index-spaces)
  ///   e.g. `Insipioid <= Nil`
  Insipoid
  // EmptyTastoid(taste: Taste(index))
  /// An impression (or aggregation) of taste
  /// e.g. Tastoid(t) -> Tastoids(t, 1)
  Tastoid(taste: Taste(of), cardinality: Int)
}

/// The empty `Tastoid`
pub const null = Insipoid

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
///     42     |> tastoid.from -> Tastoid(Taste(42, ))
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
  taste.from_one(of: index) |> from_tasting(thought: sentiment)
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
pub fn equal(t: Tastoid(index), u: Tastoid(index)) -> Bool {
  case t, u {
    Insipoid, Insipoid -> True
    _, Insipoid -> False
    Insipoid, _ -> False
    Tastoid(t, k_t), Tastoid(u, k_u) if k_t == k_u -> {
      t == u
    }
    t, u -> equal(squash(t), squash(u))
  }
}
