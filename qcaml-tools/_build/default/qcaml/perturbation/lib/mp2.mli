(* Type *)


(* [[file:~/QCaml/perturbation/mp2.org::*Type][Type:1]] *)
type t
(* Type:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/perturbation/mp2.org::*Creation][Creation:1]] *)
val make : frozen_core:Mo.Frozen_core.t -> Mo.Basis.t -> t
(* Creation:1 ends here *)

(* Access *)


(* [[file:~/QCaml/perturbation/mp2.org::*Access][Access:1]] *)
val energy      : t -> float
val mo_basis    : t -> Mo.Basis.t
val frozen_core : t -> Mo.Frozen_core.t
(* Access:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/perturbation/mp2.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
