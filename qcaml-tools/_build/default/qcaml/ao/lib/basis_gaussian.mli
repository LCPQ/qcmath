(* Type
 * 
 *   <<<~Gaussian_basis.t~>>>
 *    #+NAME: types *)

(* [[file:~/QCaml/ao/basis_gaussian.org::types][types]] *)
open Common
open Particles
open Linear_algebra
open Gaussian_integrals
open Operators

type t
(* types ends here *)

(* Access *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Access][Access:1]] *)
val basis             : t -> Gaussian.Basis.t
val cartesian         : t -> bool
val ee_ints           : t -> Eri.t
val ee_lr_ints        : t -> Eri_long_range.t
val eN_ints           : t -> Electron_nucleus.t
val f12_ints          : t -> F12.t
val f12_over_r12_ints : t -> Screened_eri.t
val kin_ints          : t -> Kinetic.t
val multipole         : t -> Multipole.t
val ortho             : t -> Orthonormalization.t
val overlap           : t -> Overlap.t
val size              : t -> int
(* Access:1 ends here *)

(* Computation  *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Computation][Computation:1]] *)
val values : t ->
             Coordinate.t ->
             Gaussian.Basis.t Vector.t
(* Computation:1 ends here *)

(* Creation *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Creation][Creation:1]] *)
val make : basis:Gaussian.Basis.t ->
           ?operators:Operator.t list ->
           ?cartesian:bool ->
           Nuclei.t ->
           t
(* Creation:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
