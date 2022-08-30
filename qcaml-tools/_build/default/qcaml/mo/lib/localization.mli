(* Type
 * 
 *    #+NAME: types *)

(* [[file:~/QCaml/mo/localization.org::types][types]] *)
open Linear_algebra
    
type localization_kind =
  | Edmiston
  | Boys

type mo = Mo_dim.t
type ao = Ao.Ao_dim.t
type loc
(* types ends here *)

(* [[file:~/QCaml/mo/localization.org::*Type][Type:2]] *)
type localization_data 
type t
(* Type:2 ends here *)

(* Access *)
   

(* [[file:~/QCaml/mo/localization.org::*Access][Access:1]] *)
val kind         : t -> localization_kind
val simulation   : t -> Simulation.t
val selected_mos : t -> int list

val kappa :
  kind:localization_kind ->
  Basis.t ->
  ( ao,loc) Matrix.t ->
  (loc,loc) Matrix.t * float

val make  :
  kind:localization_kind ->
  ?max_iter:int -> 
  ?convergence:float -> 
  Basis.t ->
  int list ->
  t

val to_basis : t -> Basis.t
(* Access:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/mo/localization.org::*Printers][Printers:1]] *)
  val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
