(* Type *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Type][Type:1]] *)
type t

open Common
(* Type:1 ends here *)

(* Access *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Access][Access:1]] *)
val atomic_shell_a         : t -> Atomic_shell.t
val atomic_shell_b         : t -> Atomic_shell.t
val contracted_shell_pairs : t -> Contracted_shell_pair.t list
val ang_mom                : t -> Angular_momentum.t
val monocentric            : t -> bool
val norm_scales            : t -> float array
val a_minus_b              : t -> Coordinate.t
val a_minus_b_sq           : t -> float
(* Access:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Creation][Creation:1]] *)
val make : ?cutoff:float -> Atomic_shell.t -> Atomic_shell.t -> t option
(* Creation:1 ends here *)



(* Creates an atomic shell pair from two atomic shells.
 * 
 * The contracted shell pairs contains the only pairs of primitives for which
 * the norm is greater than ~cutoff~. 
 * 
 * If all the contracted shell pairs are not significant, the function returns
 * ~None~. *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Creation][Creation:2]] *)
val of_atomic_shell_array : ?cutoff:float -> Atomic_shell.t array -> t option array array
(* Creation:2 ends here *)

(* Printers *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
