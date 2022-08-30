(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/particles/electrons.org::types][types]] *)
type t
(* types ends here *)

(* Creation *)


(* [[file:~/QCaml/particles/electrons.org::*Creation][Creation:1]] *)
open Common

val make : int -> int -> t

val of_atoms : ?multiplicity:int -> ?charge:int -> Nuclei.t -> t
(* @param multiplicity default is 1
   @param charge       default is 0
   @raise Invalid_argument if the spin multiplicity is not compatible with
    the molecule and the total charge.
*)
(* Creation:1 ends here *)

(* Access *)


(* [[file:~/QCaml/particles/electrons.org::*Access][Access:1]] *)
val charge       : t -> Charge.t
val n_elec       : t -> int
val n_alfa       : t -> int
val n_beta       : t -> int
val multiplicity : t -> int
(* Access:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/particles/electrons.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
