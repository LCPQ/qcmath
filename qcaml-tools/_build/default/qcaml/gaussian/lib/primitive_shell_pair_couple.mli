(** Data structure describing a couple of primitive shells pairs.

A primitive shell pair couple is the cartesian product between two sets of functions, one
set over electron one and one set over electron two. Both sets are primitive shell
pairs.

These are usually called {e shell quartets} in the literature, but we prefer to use
{e pair} for two functions with the same electron, and {e couple} for two functions
acting on different electrons, since they will be coupled by a two-electron operator.


*)

type t 

open Common

val make : Primitive_shell_pair.t -> Primitive_shell_pair.t -> t 
(** Creates a primitive shell pair couple using two primitive shell pairs.
*)

val ang_mom : t -> Angular_momentum.t
(** Total angular momentum of the shell pair couple: sum of the angular momenta of
    all the shells.  *)


val shell_a : t -> Primitive_shell.t
(** Returns the first primitive shell of the first shell pair. *)

val shell_b : t -> Primitive_shell.t
(** Returns the second primitive shell of the first shell pair. *)

val shell_c : t -> Primitive_shell.t
(** Returns the first primitive shell of the second shell pair. *)

val shell_d : t -> Primitive_shell.t
(** Returns the second primitive shell of the second shell pair. *)


val shell_pair_p : t -> Primitive_shell_pair.t
(** Returns the first primitive shell pair that was used to build the shell pair. *)

val shell_pair_q : t -> Primitive_shell_pair.t
(** Returns the second primitive shell pair that was used to build the shell pair. *)

val p_minus_q : t -> Coordinate.t
(** {% $\mathbf{P-Q}$ %}. *)


val monocentric : t -> bool
(** True if all four primitive shells have the same center. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of {!Zkey.t} relative to the four shells of the
    shell pair couple.
*)

val norm_scales : t -> float array
(** Scaling factors of normalization coefficients inside the shell. The
    ordering is the same as {!zkey_array}.
*)


