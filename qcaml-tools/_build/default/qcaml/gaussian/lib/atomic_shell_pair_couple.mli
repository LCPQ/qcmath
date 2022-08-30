(* Type *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Type][Type:1]] *)
type t

open Common
(* Type:1 ends here *)

(* Access *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Access][Access:1]] *)
val ang_mom                       : t -> Angular_momentum.t
val atomic_shell_a                : t -> Atomic_shell.t
val atomic_shell_b                : t -> Atomic_shell.t
val atomic_shell_c                : t -> Atomic_shell.t
val atomic_shell_d                : t -> Atomic_shell.t
val atomic_shell_pair_p           : t -> Atomic_shell_pair.t
val atomic_shell_pair_q           : t -> Atomic_shell_pair.t
val contracted_shell_pair_couples : t -> Contracted_shell_pair_couple.t list
val monocentric                   : t -> bool
val norm_scales                   : t -> float array
val zkey_array                    : t -> Zkey.t array
(* Access:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Creation][Creation:1]] *)
val make : ?cutoff:float -> Atomic_shell_pair.t -> Atomic_shell_pair.t -> t option
(* Creation:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/gaussian/atomic_shell_pair_couple.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
