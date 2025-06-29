import gleam/dict.{type Dict, map_values, upsert}
import gleam/float
import gleam/option.{None, Some}

/// Tastes, broadly are any indexable sentiment (or lack thereof),
/// able to participate in the Tastoid algebra 
///
/// Apart from the 0-ideal/`Nil` taste (`tasteless`), Tastes must share a
/// given index(-space) i.e. strings, Ints, or sets/combinations thereof
///
/// More algebraically:
/// 
/// Consider that the set of all Vectors are a field ℝⁿ (aka 𝕍),
/// 
/// AND  i  is an enumerable (countable) set of indices (ⅈ),
/// AND  imbed: 𝔸(..) ->  aᵢ  is a bijective imbedding of 'a'
///                            subject into 𝕍/ⅈ  
///
/// Then,  𝛂aᵢ ∈ 𝔸  are the set of all 'unit' `tastes` (scaled by 𝛂)
pub opaque type Taste(index) {
  /// Universal Identity / 0
  Nil
  Taste(index, sentiment: Float)
  Tastes(tastes: Dict(index, Float))
  // Idea: BroadTastes (each tᵢ has its own k, don't diminish others)
  // Idea: ImmutableTaste(sentiment | index->sentiment) -- unchanging
  // Idea: ComplexTaste (allow tastes values to complex (mod n))
  // Idea: ... TastoidsTaste({set of i in 𝕥}: 𝕥)! (I'd bet it'll work)
}

/// Alias for `Nil`, the empty taste—sans index—shared by every embedding-space
pub const tasteless = Nil

// Return a Taste(index, sentiment)
pub fn from_sentiment(sentiment: Float, of index: index) -> Taste(index) {
  case sentiment {
    0.0 -> tasteless
    _ -> Taste(index, sentiment)
  }
}

/// Return a Taste(...) composed of the indexed sentiments.
pub fn from_tuples(from indexed_tastes: List(#(index, Float))) -> Taste(index) {
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

/// Scale the given tastes by its 'weight' (relative to its 'natural' values)
/// a la scalar multiplication
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
fn non_zeroes(_, t: Float) {
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
