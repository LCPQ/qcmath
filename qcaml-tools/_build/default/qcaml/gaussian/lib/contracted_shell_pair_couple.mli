(** Data structure describing a couple of contracted shells pairs.

A contracted shell pair couple is the cartesian product between two sets of functions, one
set over electron one and one set over electron two. Both sets are contracted shell
pairs.

These are usually called {e shell quartets} in the literature, but we prefer to use
{e pair} for two functions with the same electron, and {e couple} for two functions
acting on different electrons, since they will be coupled by a two-electron operator.


*)

type t 

open Common

val make : ?cutoff:float -> Contracted_shell_pair.t -> Contracted_shell_pair.t -> t option
(** Creates a contracted shell pair couple using two contracted shell pairs.
*)

val ang_mom : t -> Angular_momentum.t
(** Total angular momentum of the shell pair couple: sum of the angular momenta of
    all the shells.  *)


val shell_a : t -> Contracted_shell.t
(** Returns the first contracted shell of the first shell pair. *)

val shell_b : t -> Contracted_shell.t
(** Returns the second contracted shell of the first shell pair. *)

val shell_c : t -> Contracted_shell.t
(** Returns the first contracted shell of the second shell pair. *)

val shell_d : t -> Contracted_shell.t
(** Returns the second contracted shell of the second shell pair. *)


val shell_pair_p : t -> Contracted_shell_pair.t
(** Returns the first contracted shell pair that was used to build the shell pair. *)

val shell_pair_q : t -> Contracted_shell_pair.t
(** Returns the second contracted shell pair that was used to build the shell pair. *)

val monocentric : t -> bool
(** True if all four contracted shells have the same center. *)

val coefs_and_shell_pair_couples : t -> (float * Primitive_shell_pair_couple.t) list
(** Returns the list of significant shell pair couples. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of {!Zkey.t} relative to the four shells of the
    shell pair couple.
*)

val norm_scales : t -> float array
(** Scaling factors of normalization coefficients inside the shell. The
    ordering is the same as {!zkey_array}.
*)


