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
import gleam/list
import gleam/option.{None, Some}
import gleam/set

/// A `Taste` of a given `index` with `value`s sharing the same types.
pub opaque type Taste {
  /// Universal Identity / 0
  Nil
  Taste(of: String, was: Float)
  Tastes(tastes: Dict(String, Float))
  SparseEmbedding(values: List(Float), indices: List(Int))
  DenseEmbedding(values: List(Float))
  // Idea: BroadTastes (each tᵢ has its own k, don't diminish others)
  // Idea: ImmutableTaste(sentiment | index->sentiment) -- unchanging
  // Idea: ComplexTaste (allow tastes values to complex (mod n))
  // Idea: ... TastoidsTaste({set of i in 𝕥}: 𝕥)! (I'd bet it'll work)
}

/// Alias for `Nil`, the empty taste—sans index—shared by every embedding-space
pub const tasteless = Nil

/// Return a singular of 'index', a la `Taste(index, 1.0)`
pub fn from_one(of index: String) {
  Taste(of: index, was: 1.0)
}

/// Return a `Tastes(index)` consisting of the provided #(index, value: Float) tuples.
pub fn from_tuples(from tastes: List(#(String, Float))) {
  dict.from_list(tastes) |> Tastes
}

pub fn from_sparse_embedding(values: List(Float), by indices: List(Int)) {
  SparseEmbedding(values, indices)
}

pub fn from_dense_embedding(values: List(Float)) {
  DenseEmbedding(values)
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
pub fn scale(taste: Taste, by weight: Float) -> Taste {
  let scale_by_weight = fn(sentiment: Float) {
    float.multiply(sentiment, weight)
  }
  case taste {
    DenseEmbedding(ts) ->
      ts |> list.map(with: scale_by_weight) |> DenseEmbedding
    SparseEmbedding(ts, indices) ->
      ts |> list.map(with: scale_by_weight) |> SparseEmbedding(indices)
    Tastes(ts) ->
      map_values(ts, with: scaling_values(by: weight))
      |> Tastes
    Taste(i, sentiment) -> Taste(i, scale_by_weight(sentiment))
    Nil -> taste
  }
}

/// Internal: Short-hand for `dict.filter` keeping only non-zero tastes
fn non_zeroes(_, t: Float) {
  t != 0.0
}

/// Internal: Simplify a taste(s) by recursively excising zeroed tastes, collapsing
/// the smallest possible representation (ensuring direct equality when possible)
fn deflate(taste t: Taste) {
  case t {
    // TBD, for now don't do inflating on dense/sparse embeddings at all
    DenseEmbedding(_) -> t
    SparseEmbedding(_, _) -> t
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
pub fn add(taste t: Taste, to u: Taste) -> Taste {
  let sum = case t, u {
    DenseEmbedding(ts), DenseEmbedding(us) ->
      list.map2(ts, us, with: float.add) |> DenseEmbedding
    SparseEmbedding(ts, t_indices), SparseEmbedding(us, u_indices) -> {
      let ts_dict = list.zip(t_indices, ts) |> dict.from_list
      let us_dict = list.zip(u_indices, us) |> dict.from_list

      let #(indices, tus) =
        dict.combine(ts_dict, us_dict, with: float.add)
        |> dict.filter(keeping: non_zeroes)
        |> dict.to_list
        |> list.unzip

      SparseEmbedding(tus, indices)
    }
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
    _, _ -> Nil
  }

  sum |> deflate
}

fn map_negate(ts: List(Float)) -> List(Float) {
  ts |> list.map(with: float.negate)
}

/// Returns the 'negative' of a taste (like <-> dislike)
pub fn negate(t: Taste) -> Taste {
  case t {
    DenseEmbedding(ts) -> ts |> map_negate |> DenseEmbedding
    SparseEmbedding(ts, indices) -> ts |> map_negate |> SparseEmbedding(indices)
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
pub fn multiply(t: Taste, by u: Taste) -> Taste {
  case t, u {
    Nil, _ -> Nil
    _, Nil -> Nil
    DenseEmbedding(ts), DenseEmbedding(us) ->
      list.map2(ts, us, with: float.multiply) |> DenseEmbedding
    SparseEmbedding(ts, t_indices), SparseEmbedding(us, u_indices) -> {
      let t_set = set.from_list(t_indices)
      let u_set = set.from_list(u_indices)
      case set.is_disjoint(t_set, u_set) {
        True -> Nil
        False -> {
          let excluded_indices =
            set.symmetric_difference(of: t_set, and: u_set) |> set.to_list
          let ts_dict =
            list.zip(t_indices, ts)
            |> dict.from_list
            |> dict.drop(excluded_indices)
          let us_dict =
            list.zip(u_indices, us)
            |> dict.from_list
            |> dict.drop(excluded_indices)
          // Both dicts should have the same set of keys now, so we can
          // expect combine to not 'pass-through' unshared values
          let product =
            dict.combine(ts_dict, us_dict, with: float.multiply)
            |> dict.filter(keeping: fn(_k, v) { v != 0.0 })
          let #(indices, values) = dict.to_list(product) |> list.unzip
          SparseEmbedding(values, indices)
        }
      }
    }

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
    // nb. The types are incompatible
    _, _ -> Nil
  }
}

fn absolute_length(of tastes: List(Float)) -> Float {
  tastes
  |> list.map(with: float.absolute_value)
  |> list.fold(from: 0.0, with: float.add)
}

/// Returns the combined sentiments of the entire Taste.
pub fn length(of taste: Taste) -> Float {
  case taste {
    DenseEmbedding(ts) -> absolute_length(ts)
    SparseEmbedding(ts, _) -> absolute_length(ts)
    Tastes(ts) ->
      fold(ts, 0.0, fn(sum, _index, sentiment) {
        sentiment |> float.absolute_value |> float.add(sum)
      })
    Taste(_, sentiment) -> sentiment
    Nil -> 0.0
  }
}

import gleam/string

/// Returns a combined taste, where n taste indices become one set of its
/// indices, with its value representing the sum of their sentiments.
pub fn condense(taste: Taste) -> Taste {
  let sum = length(taste)
  case taste {
    DenseEmbedding(_) -> taste
    SparseEmbedding(ts, indices) -> {
      let #(condensed_indices, condensed_ts) =
        list.zip(indices, ts)
        |> list.filter(keeping: fn(key_value) { key_value.1 != 0.0 })
        |> list.unzip
      SparseEmbedding(condensed_ts, condensed_indices)
    }
    Tastes(ts) ->
      ts
      |> dict.keys
      |> list.sort(by: string.compare)
      |> list.intersperse("⩐")
      |> list.fold(from: "", with: string.append)
      |> Taste(sum)
    Taste(_, _) -> taste
    Nil -> Nil
  }
}
