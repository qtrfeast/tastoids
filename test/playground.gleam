pub fn approximates_a_freq_count_test() {
  // I've noticed if you use a 1-weighted
  // Tastoid of string words, the result of
  // repeatedly blending words yields a
  // k=<word count> Tastoid whose indices
  // are the unique words present and whose
  // values are the number of occurances.
  //
  // Squashing this Tastoid to 1 yields what
  // is effectively the _dense_ embedding of
  // the body of text.
  todo
}

pub fn experiment_tastoids_of_musical_chords_test() {
  // Hypothesis:
  // IF, you made a Tastoid of every uniform way to write a Chord (C, Cm, Asus7dim...)
  // by character
  // THEN, grouped those Tastoids by their 'hottest' index, would be A, B, C, D, E, F, G.
  // AND, if you blend those subgroups further, the 7 Tastoids you have
  // THEN, for any unknown chord, the one of those it is closest to is its main note.
  // (And I suspect it will be the same closeness to the remaining 6)
  todo
}

pub fn distance_allows_partial_derivatives_test() {
  todo
}

pub fn distance_allows_del_derivatives_test() {
  todo
}
