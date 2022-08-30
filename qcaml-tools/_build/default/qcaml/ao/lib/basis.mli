(* Types
 * 
 *    <<<~Basis.t~>>> *)

(* [[file:~/QCaml/ao/basis.org::*Types][Types:1]] *)
type t
type ao = Ao_dim.t 

open Common
open Particles
open Operators
open Linear_algebra
(* Types:1 ends here *)

(* Conversions *)


(* [[file:~/QCaml/ao/basis.org::*Conversions][Conversions:1]] *)
val of_nuclei_and_basis_filename :
  ?kind:[> `Gaussian ] ->
  ?operators:Operator.t list ->
  ?cartesian:bool ->
  nuclei:Nuclei.t ->
  string ->
  t
(* Conversions:1 ends here *)

(* Access *)


(* [[file:~/QCaml/ao/basis.org::*Access][Access:1]] *)
val size              : t -> int
val ao_basis          : t -> Basis_poly.t
val overlap           : t -> (ao,ao) Matrix.t
val multipole         : t -> string -> (ao,ao) Matrix.t
val ortho             : t -> (ao,'a) Matrix.t
val eN_ints           : t -> (ao,ao) Matrix.t
val kin_ints          : t -> (ao,ao) Matrix.t
val ee_ints           : t -> ao Four_idx_storage.t
val ee_lr_ints        : t -> ao Four_idx_storage.t
val f12_ints          : t -> ao Four_idx_storage.t
val f12_over_r12_ints : t -> ao Four_idx_storage.t
val cartesian         : t -> bool
val values            : t -> Coordinate.t -> ao Vector.t
(* Access:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/ao/basis.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
