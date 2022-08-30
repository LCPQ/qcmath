(** Contains the conventions relative to the program.

  The phase convention is given by:
  {% $\sum_i c_i > 0$ %} or {% $\min_i c_i \ge  0$ %}

*)


val in_phase : 'a Vector.t -> bool
(** Checks if one MO respects the phase convention *)

val rephase : ('a,'b) Matrix.t -> ('a,'b) Matrix.t
(** Apply the phase convention to the MOs. *)

