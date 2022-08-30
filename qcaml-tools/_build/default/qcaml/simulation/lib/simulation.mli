(* Simulation
 *   :PROPERTIES:
 *   :header-args: :noweb yes :comments both
 *   :END:
 * 
 *   Contains the state of the simulation.
 *   
 *   #+NAME: open *)

(* [[file:~/QCaml/simulation/simulation.org::open][open]] *)
open Common
open Particles
open Operators
(* open ends here *)

(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/simulation/simulation.org::types][types]] *)
type t
(* types ends here *)

(* Access *)


(* [[file:~/QCaml/simulation/simulation.org::*Access][Access:1]] *)
val nuclei            : t -> Nuclei.t
val charge            : t -> Charge.t
val electrons         : t -> Electrons.t
val ao_basis          : t -> Ao.Basis.t
val nuclear_repulsion : t -> float
val operators         : t -> Operator.t list
(* Access:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/simulation/simulation.org::*Creation][Creation:1]] *)
val make : ?multiplicity:int -> ?charge:int -> 
  ?operators:Operator.t list-> nuclei:Nuclei.t ->
  Ao.Basis.t -> t
(* Creation:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/simulation/simulation.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
