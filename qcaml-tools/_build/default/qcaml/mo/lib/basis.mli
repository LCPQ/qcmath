(** Data structure to represent the molecular orbitals.

    The MO indices start from 1.
    
*)

open Linear_algebra
open Common
       
type mo_type =
  | RHF | ROHF | UHF | CASSCF | Projected
  | Natural of string
  | Localized of string
      
type t
type mo = Mo_dim.t
type ao = Ao.Ao_dim.t

(** {1 Accessors} *)

val simulation : t -> Simulation.t
(** Simulation which produced the MOs *)

val mo_type : t -> mo_type
(** Kind of MOs (RHF, CASSCF, Localized...) *)

val ao_basis : t -> Ao.Basis.t
(** Matrix of the MO coefficients in the AO basis *)

val mo_occupation : t -> mo Vector.t
(** Occupation numbers *)

val mo_coef : t -> (ao, mo) Matrix.t
(** Molecular orbitcal coefficients *)

val eN_ints : t -> (mo,mo) Matrix.t
(** Electron-nucleus potential integrals *)

val ee_ints : t -> mo Four_idx_storage.t
(** Electron-electron repulsion integrals *)

val kin_ints : t -> (mo,mo) Matrix.t
(** Kinetic energy integrals *)

val one_e_ints : t -> (mo,mo) Matrix.t
(** One-electron integrals {% $\hat{T} + V$ %} *)

val two_e_ints : t -> mo Four_idx_storage.t
(** Electron-electron repulsion integrals *)

(* TODO
val f12_ints : t -> F12.t
(** F12 integrals *)
*)

val size : t -> int
(** Number of molecular orbitals in the basis *)

val mo_energies : t -> mo Vector.t
(** Fock MO energies *)

val values : t -> Coordinate.t -> mo Vector.t
(** Values of the MOs evaluated at a given coordinate. *)

(** {1 Creators} *)

val make : simulation:Simulation.t ->
  mo_type:mo_type ->
  mo_occupation:mo Vector.t ->
  mo_coef:(ao,mo) Matrix.t ->
  unit -> t
(** Function to build a data structure representing the molecular orbitals. *)

val of_hartree_fock : Hartree_fock.t -> t
(** Build MOs from a Restricted Hartree-Fock calculation. *)

(*
val of_mo_basis : Simulation.t -> t -> t
(** Project the MOs of the other basis on the current one. *)
*)


val mo_matrix_of_ao_matrix :
  mo_coef:(ao,mo) Matrix.t ->
  (ao,ao) Matrix.t -> (mo,mo) Matrix.t
(** Build a matrix in MO basis from a matrix in AO basis. *)

val ao_matrix_of_mo_matrix :
  mo_coef:(ao,mo) Matrix.t -> ao_overlap:(ao,ao) Matrix.t ->
  (mo,mo) Matrix.t -> (ao,ao) Matrix.t
(** Build a matrix in AO basis from a matrix in MO basis. *)

(** {1 Printers} *)

val pp : ?start:int -> ?finish:int -> Format.formatter -> t -> unit
        
 

