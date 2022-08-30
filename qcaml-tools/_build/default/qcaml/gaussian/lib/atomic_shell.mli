(* Type *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Type][Type:1]] *)
type t

open Common
(* Type:1 ends here *)

(* Access *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Access][Access:1]] *)
val ang_mom           : t -> Angular_momentum.t
val center            : t -> Coordinate.t
val coefficients      : t -> float array array
val contracted_shells : t -> Contracted_shell.t array
val exponents         : t -> float array array
val index             : t -> int
val normalizations    : t -> float array array
val norm_scales       : t -> float array
val size_of_shell     : t -> int
val size              : t -> int
(* Access:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Creation][Creation:1]] *)
val make : ?index:int -> Contracted_shell.t array -> t 

val with_index  : t -> int -> t
(* Creation:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/gaussian/atomic_shell.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
