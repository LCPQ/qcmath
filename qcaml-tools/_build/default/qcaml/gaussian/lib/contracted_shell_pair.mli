(** A datastructure to represent pairs of contracted shells.

A contracted shell pair is a product of two {!Contracted_shell.t}:

{% \begin{align*}
\varphi_{ab}(r) & = \chi_a(r) \times \chi_b(r) \\
& = P_a \sum_{i=1}^{m_a} \mathcal{N}_i^a f_i[P_a] d_i^a \exp \left( -\alpha_i^a |r-R_a|^2 \right) \times 
    P_b \sum_{j=1}^{m_b} \mathcal{N}_j^b f_j[P_b] d_j^b \exp \left( -\alpha_j^b |r-R_b|^2 \right) \\
& = P_a P_b \sum_{i=1}^{m_a} \sum_{j=1}^{m_b} \left( \mathcal{N}_i^a \mathcal{N}_j^b \right) \left( f_i[P_a] f_j[P_b] \right) \left( d_i^a d_j^b \right) \exp \left( -\alpha_i^a |r-R_a|^2 -\alpha_j^b |r-R_b|^2 \right) \\
\end{align*} %}

*)

type t

open Common

val make : ?cutoff:float -> Contracted_shell.t -> Contracted_shell.t -> t option
(** Creates an contracted shell pair {% $\varphi_{ab}$ %} from a contracted
    shell {% $\chi_a$ %} (first argument) and a contracted shell {% $\chi_b$ %}
    (second argument).

    The contracted shell pair contains the only pairs of primitives for which
    the norm is greater than [cutoff]. 

    The function returns [None] if all the primitive shell pairs are not
    significant, or if the index of the 1st primitive is smaller than the index
    of the second primitive.

*)


val of_contracted_shell_array : ?cutoff:float -> Contracted_shell.t array -> t list
(** Creates all possible contracted shell pairs from an array of contracted shells.
    Only significant shell pairs are kept.
*)

val shell_a : t -> Contracted_shell.t
(** Returns the first {!Contracted_shell.t}  {% $\chi_a$ %} which was used to
    build the contracted shell pair.
*)

val shell_b : t -> Contracted_shell.t
(** Returns the second {!Contracted_shell.t} {% $\chi_b$ %} which was used to
    build the contracted shell pair.
*)

val coefs_and_shell_pairs : t -> (float * Primitive_shell_pair.t) list
(** Returns an arra of coefficients and of {!Primitive_shell_pair.t}, containing all
    the pairs of primitive functions used to build the contracted shell pair.
*)

val shell_pairs : t -> Primitive_shell_pair.t array
(** Returns an array of {!Primitive_shell_pair.t}, containing all the pairs of
    primitive functions used to build the contracted shell pair.
*)

val coefficients : t -> float array

val exponents_inv : t -> float array


val a_minus_b : t -> Coordinate.t
  (* A-B *)

val a_minus_b_sq : t -> float
  (* |A-B|^2 *)

val norm_scales : t -> float array
  (* normalizations.(i) / normalizations.(0) *)

val ang_mom : t -> Angular_momentum.t
  (* Total angular Momentum *)

val monocentric : t -> bool
(** If true, the two contracted shells have the same center. *)

val zkey_array : t -> Zkey.t array
(** Returns the array of Zkeys associated with the contracted shell pair. *)

val compare : t -> t -> int
(** Comparison function for sorting *)

(*
val hash : t -> int array
val cmp : t -> t -> int
val equivalent : t -> t -> bool
val unique : 'a array array array -> 'a array list
val indices : 'a array array array -> (int array, int * int) Hashtbl.t
*)
