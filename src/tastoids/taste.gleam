//// Tastes, broadly are any indexable sentiment (or lack thereof),
//// able to participate in the Tastoid algebra 
////
//// Apart from the 0-ideal/`Nil` taste (`tasteless`), Tastes must share a
//// given index(-space) i.e. strings, Ints, or sets/combinations thereof
////
//// More algebraically:
//// 
//// Consider that the set of all Vectors are a field ℝⁿ (aka 𝕍),
//// AND  i is an enumerable (countable) set of indices (ⅈ) with
//// `imbed(a ∈ 𝔸) ->  aᵢ` (a bijective imbedding of 'a' subject into 𝕍/ⅈ)
////
//// Then,  𝛂aᵢ ∈ 𝔸  are the set of all 'unit' `tastes` (scaled by 𝛂)

import gleam/dict.{type Dict, fold, map_values, upsert}
import gleam/float
import gleam/option.{None, Some}
import gleam/set.{type Set}

// I'd like to parameterize Taste by Int/Float (tbd...)
type Value =
  Float

/// A `Taste` of a given `index` with `value`s sharing the same types.
pub opaque type Taste(index) {
  /// Universal Identity / 0
  Nil
  Taste(of: index, was: Value)
  Tastes(tastes: Dict(index, Value))
  // Idea: BroadTastes (each tᵢ has its own k, don't diminish others)
  // Idea: ImmutableTaste(sentiment | index->sentiment) -- unchanging
  // Idea: ComplexTaste (allow tastes values to complex (mod n))
  // Idea: ... TastoidsTaste({set of i in 𝕥}: 𝕥)! (I'd bet it'll work)
}

/// Alias for `Nil`, the empty taste—sans index—shared by every embedding-space
pub const tasteless = Nil

/// Return a singular of 'index', a la `Taste(index, 1.0)`
pub fn from_one(of index: index) -> Taste(index) {
  Taste(of: index, was: 1.0)
}

/// Return a `Tastes(index)` consisting of the provided #(index, value: Float) tuples.
pub fn from_tuples(from indexed_tastes: List(#(index, Value))) -> Taste(index) {
  dict.from_list(indexed_tastes) |> Tastes
}

/// Internal: Short-hand for use in `scalar_multiply`; curries weight w/ float.multiply
fn scaling(by weight: Float) {
  fn(taste: Float) { float.multiply(weight, taste) }
}

/// Internal: curry weight `scaling` further for `dict.map_values` to ignore the index
fn scaling_values(by weight: Float) {
  let scaled = scaling(by: weight)
  fn(_, sentiment) { sentiment |> scaled }
}

/// Scale the given tastes by a portion (_weight_)–relative to its
///'natural' values–a la scalar multiplication.
///
/// _Note from Avery: While this could be accomplished via a Tastoid's
/// cardinality, I wanted keep the notion of a signal's 'worth' (the
///_scale_ of its impression) distinct from its quantity.
pub fn scale(taste: Taste(index), by weight: Float) -> Taste(index) {
  let scale_by_weight = fn(sentiment: Float) {
    float.multiply(sentiment, weight)
  }
  case taste {
    Tastes(ts) ->
      map_values(ts, with: scaling_values(by: weight))
      |> Tastes
    Taste(i, sentiment) -> Taste(i, scale_by_weight(sentiment))
    Nil -> taste
  }
}

/// Internal: Short-hand for `dict.filter` keeping only non-zero tastes
fn non_zeroes(_, t: Value) {
  t != 0.0
}

/// Internal: Simplify a taste(s) by recursively excising zeroed tastes, collapsing
/// the smallest possible representation (ensuring direct equality when possible)
fn deflate(taste t: Taste(index)) {
  case t {
    // For plural tastes, flatten into Nil if empty
    Tastes(ts) -> {
      let zeroless_ts = ts |> dict.filter(keeping: non_zeroes)
      case dict.size(zeroless_ts) {
        0 -> Nil
        n if n > 1 -> zeroless_ts |> Tastes
        _ -> {
          case dict.to_list(ts) {
            [#(index, sentiment)] -> Taste(index, sentiment) |> deflate
            _ -> t
          }
        }
      }
    }
    Taste(_, sentiment) if sentiment == 0.0 -> Nil
    Taste(_, _) -> t
    Nil -> Nil
  }
}

/// Combine two tastes, linearly adding their sentiments (per index)
/// a la 'scalar addition'
pub fn add(taste t: Taste(index), to u: Taste(index)) -> Taste(index) {
  let sum = case t, u {
    // Adding two single tastes of the same index adds them directly
    Taste(t_i, sentiment_t), Taste(index_u, sentiment_u) if t_i == index_u ->
      Taste(t_i, float.add(sentiment_t, sentiment_u)) |> deflate

    // Joining two single tastes of different indices yields a Tastes
    Taste(t_i, sentiment_t), Taste(index_u, sentiment_u) ->
      dict.from_list([#(t_i, sentiment_t), #(index_u, sentiment_u)])
      |> dict.filter(keeping: non_zeroes)
      |> Tastes

    // An existing tastes upserts new singular tastes
    Taste(_, _), Tastes(_) -> add(u, t)
    Tastes(ts), Taste(index_u, sentiment_u) ->
      upsert(ts, index_u, fn(sentiment_t) {
        case sentiment_t {
          Some(sentiment_t) -> float.add(sentiment_t, sentiment_u)
          None -> sentiment_u
        }
      })
      |> dict.filter(keeping: non_zeroes)
      |> Tastes

    // Adding many to a single is just the previous but swapped arguments
    // Two plural tastes are a additive merge
    Tastes(t), Tastes(u) ->
      dict.combine(t, u, with: fn(sentiment_t, sentiment_u) {
        float.add(sentiment_t, sentiment_u)
      })
      |> dict.filter(keeping: non_zeroes)
      |> Tastes

    Nil, _ -> u
    _, Nil -> t
  }

  sum |> deflate
}

/// Returns the 'negative' of a taste (like <-> dislike)
pub fn negate(t: Taste(index)) -> Taste(index) {
  case t {
    Tastes(ts) ->
      map_values(ts, fn(_i, sentiment) { float.negate(sentiment) })
      |> Tastes
    Taste(i, sentiment) -> Taste(i, float.negate(sentiment))
    Nil -> t
  }
}

/// Return the _and_-ish product of two tastes. Multiplying the
/// indices between—possibly sparse—amplifying shared indices and
/// nullifying ones they don't (i.e. they were multiplied by zero).
pub fn multiply(t: Taste(space), by u: Taste(space)) -> Taste(space) {
  case t, u {
    Nil, _ -> Nil
    _, Nil -> Nil
    // Misaligned singular Tastes cancel-out (implied x 0)
    Taste(i1, _), Taste(i2, _) if i1 != i2 -> Nil
    // Aligned singular Taste(s) multiply normally.
    Taste(i, t1), Taste(_i, t2) -> Taste(i, float.multiply(t1, t2))
    // One-to-many multiplication is fairly direct
    Taste(_, _), Tastes(_) -> multiply(u, t)
    Tastes(ts), Taste(i, t1) -> {
      case dict.get(ts, i) {
        Ok(t2) ->
          case t2 {
            0.0 -> Nil
            _ -> Taste(i, float.multiply(t1, t2))
          }
        Error(_) -> Nil
      }
    }
    Tastes(ts1), Tastes(ts2) -> {
      dict.combine(ts1, ts2, float.multiply)
      |> dict.filter(keeping: non_zeroes)
      |> Tastes
    }
  }
}

/// Returns the combined sentiments of the entire Taste.
pub fn length(of taste: Taste(index)) -> Value {
  case taste {
    Tastes(ts) ->
      fold(ts, 0.0, fn(sum, _index, sentiment) {
        sentiment |> float.absolute_value |> float.add(sum)
      })
    Taste(_, sentiment) -> sentiment
    Nil -> 0.0
  }
}

/// Returns the combined set of sentiment indices of a Taste
pub fn indices(of taste: Taste(index)) -> Set(index) {
  case taste {
    Tastes(ts) -> ts |> dict.keys |> set.from_list
    Taste(i, _) -> set.from_list([i])
    Nil -> set.new()
  }
}

/// Returns a combined taste, where n taste indices become one set of its
/// indices, with its value representing the sum of their sentiments.
pub fn condense(taste: Taste(index)) -> Taste(Set(index)) {
  let sum = length(taste)
  Taste(indices(of: taste), sum)
}
