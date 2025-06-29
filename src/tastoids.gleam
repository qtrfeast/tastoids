//// Tastoids (& their 'Temperate' Algebra)
////
//// It is often said, one can't compare "apples" to "oranges",
//// but I daresay.. _perhaps you can?_
////
////   **Let me show you how.**
////
//// On their own, it is hard to figure how one might compare apples to oranges,
//// let alone deign to approach a calculus of taste however, with _just enough_
//// structure , a **Taste** can become a **Tastoid**, along with a curious and powerful
////  _Temperate_ Algebra.
////
//// > Not unlike a [_Tropical_ geometry](https://en.wikipedia.org/wiki/Tropical_geometry),
//// > where the notion of addition and multiplication are replaced by min(a,b) & add(a,b),
//// > I pose that a _Temperate Algebra_ is one whose typical notions of (+,×) are replaced
//// > with operations that effectively 'average' taste (with commutativity, distributivity
//// > and reversibility, no less!)
//// 
////  ### A Taste (t) Field
//// "Tastes", broadly, are any measurable/comparable sentiment about a thing. Something
//// with a unique direction and magnitude. _A vector!_
//// 
//// Consider if you will, then:
////
////  - The set of all Vectors are a field ℝⁿ (aka 𝕍).
////  - You may partition 𝕍 by some enumerable set of indices (as ⅈ <= countable ∞))
////  - The '[Algebraic extension](https://en.wikipedia.org/wiki/Algebraic_extension)'
////    of 𝕍/ⅈ, is itself a field (with Algebra)
////
//// > In the context of large-language- and embedding-models, this idea of mapping _things_
//// > (text or otherwise) into a well-defined set of possible indices and probabilities is
//// > referred to as an '_embedding_'.
////
//// ### A Taste -> One Tastoid
////
//// We're almost there, I promise. Lets talk about plain numbers for a bit; say I told you
//// knew the average of some set of values was 42. You also know for a fact there was a 13
//// in there once, somewhere.
////
//// Knowing nothing else, how would you _un_-average 13 from 42?
////
//// _Were there two values that averaged to 42? Three? More?_
////
//// Without the _cardinality_ of the original sampling, its (absolutely) impossible to know.
//// But with it... say n=13, in which case, we can merely remove 1/13th of 13 (i.e. 1)
//// from our combined average to find out the average without that 13 was just 41.
////
//// Similarly, on their own Taste vectors _are_ comparable, even averagable in some sense,
//// but without a cardinality, their operations aren't quite _lined up_ to have solutions
//// to previously impossible questions become possible and yield seemingly 'free' results.
////
//// Attempting to put some formalism to the above,
//// 
////   - We can partition a taste-field further, by its cardinality k ∈ 𝕂 (𝕂 ~ ℝ x ℝ₄ ~ ℂ)
////     (As well as a 4-cycle of like -> dislike -> unlike -> undislike)
//// 
////     i.e.  someone (or thing) expressing      {    like ( 1+i )     ->  dislike (-1 + i)
////       𝕒 taste (valued at weight w), k times   -> un-like (-1 + -i) -> un-dislike (1 + -i) } 
//// A Tastoid, can be arrived at by a person/subject, expressing a taste _once_ (tᵢ, k=1), 
//// imbedding (sic) that individuals' sentiment in a univesal/possibly infinite set of all
//// the tastoid's that subject could express 𝕥ᵤ↪ᵢ ∈ 𝕋ᵤ
////
////  Then, we may define a handful a tiny, tidy, yet supremely powerful (σ/sigma-)
////    _Algebra_ of Taste_
////
//// - [ ] Brief introduction to operators

// 
// ### Operations
//
//  - [ ] Tidy this up with all the more recent changes; probably into a more formal
//        'proof'ing ground
// 
//  (A thorough reckoning of its axioms will take time, learning, and discourse with others;
//   suffice to say I mean a formal category-theory 'Algebra' with several handy properties,
//   notably invertible, self-integrating distillation of an 'average' taste!)
//   
//   - add(t¹, u¹) -> (t + u)¹       ('regular' properties of scalar vector addition)
//   - scale(tⁿ, k)   -> tⁿᵏ         ('regular' properties of scalar vector multiplication)
//   - blend(t¹, u¹))  ->  (t + u)²  ('tensor' product;  associative, distributive, commutative, invertable)
//       (equiv. to)  ~> (½t + ½u)¹
//   - squash(tᵏ, p)  ->   ||t||ₚ   ( for p =0, yields the unipotent norm--i.e. every sparse tᵢ -> 1
//                                        p==1, yields the normal tastoid (weighted power mean)
//                                        p!=0, yields the p-norm of t with k=p )

import gleam/float
import gleam/int
import tastoids/taste.{add, negate, scale}
import tastoids/tastoid.{type Tastoid, Tasteless, Tastoid}

/// Blend the two tastoids, producing a larger tastoid  congruent to
/// the weighted power mean, aka their average (via `squash`)
///
/// See also `retract` - which yields u' which _unblends_ when blended,
pub fn blend(t: Tastoid(index), with u: Tastoid(index)) {
  case t, u {
    Tasteless, _ -> u
    _, Tasteless -> t
    Tastoid(t, k_t), Tastoid(u, k_u) -> add(t, u) |> Tastoid(int.add(k_t, k_u))
  }
}

/// Return the inverse of a taste (over `blend`)
pub fn retract(taste: Tastoid(index)) -> Tastoid(index) {
  case taste {
    Tastoid(t, k) -> negate(t) |> Tastoid(int.negate(k))
    Tasteless -> Tasteless
  }
}

/// Reduce k -> 1, yielding the 'average'/normalized tastoid of all
/// the tastoids blended/present
pub fn squash(tastoid: Tastoid(index)) {
  case tastoid {
    // Squashing a k=1 tastoid is the base case, so it returns unchanged.
    Tastoid(_, 1) as t -> t
    // A 0-strength taste squashes towards the emptiest taste (Null)
    Tastoid(_, 0) -> Tasteless
    // When k is non-zero, return the de-weighted norm of t (scale by 1 over k)
    Tastoid(t, k) -> {
      // A special coefficient that grounds t into k=1 when applied via scalar multiplication
      let try_divide = float.divide(1.0, int.to_float(k))
      case try_divide {
        Ok(one_over_k) -> scale(t, by: one_over_k) |> Tastoid(1)
        Error(_) -> Tasteless
      }
    }
    Tasteless -> Tasteless
  }
}

/// Combine two tastoids _hard_, blending them and returing their squashed mean.
pub fn smash(t: Tastoid(index), with u: Tastoid(index)) -> Tastoid(index) {
  blend(t, u) |> squash
}

/// Returns `True` iff Tastoids `t` & `u` are congruent (weakly equivalent)
pub fn equal(t: Tastoid(index), u: Tastoid(index)) -> Bool {
  case t, u {
    Tasteless, Tasteless -> True
    _, Tasteless -> False
    Tasteless, _ -> False
    Tastoid(t, k_t), Tastoid(u, k_u) if k_t == k_u -> {
      t == u
    }
    t, u -> equal(squash(t), squash(u))
  }
}
