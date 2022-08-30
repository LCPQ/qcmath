(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/mo/frozen_core.org::types][types]] *)
type kind =
  | All_electron
  | Small
  | Large
(* types ends here *)

(* [[file:~/QCaml/mo/frozen_core.org::*Type][Type:2]] *)
type t
(* Type:2 ends here *)

(* Creation *)


(* [[file:~/QCaml/mo/frozen_core.org::*Creation][Creation:1]] *)
val make : kind -> Particles.Nuclei.t -> t

val of_int_list  : int list  -> t
val of_int_array : int array -> t
(* Creation:1 ends here *)

(* Access *)


(* [[file:~/QCaml/mo/frozen_core.org::*Access][Access:1]] *)
val num_elec : t -> int
val num_mos  : t -> int
(* Access:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/mo/frozen_core.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
