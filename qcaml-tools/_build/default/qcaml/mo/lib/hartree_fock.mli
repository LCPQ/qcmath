open Linear_algebra

(** Data structure representing the output of a Hartree-Fock caculation *)

type hartree_fock_data

type hartree_fock_kind =
| RHF       (** Restricted Hartree-Fock *)
| ROHF      (** Restricted Open-shell Hartree-Fock *)
| UHF       (** Unrestricted Hartree-Fock *)


type t
type mo = Mo_dim.t
type ao = Ao.Ao_dim.t

val kind : t -> hartree_fock_kind
(** Kind of simulation  : RHF, ROHF or UHF. *)

val simulation : t -> Simulation.t
(** Simulation which was used for HF calculation *)

val guess : t -> Guess.t
(** Initial guess *)

val eigenvectors : t -> (ao, mo) Matrix.t
(** Final eigenvectors *)

val eigenvalues : t -> mo Vector.t
(** Final eigenvalues  *)

val occupation : t -> mo Vector.t
(** Diagonal of the density matrix *)

val energy : t -> float
(** Final energy *)

val nuclear_repulsion : t -> float
(** Nucleus-Nucleus potential energy *)

val kin_energy : t -> float
(** Kinetic energy *)

val eN_energy : t -> float
(** Electron-nucleus potential energy *)
                                                                                              
val coulomb_energy : t -> float 
(** Electron-Electron potential energy *)

val exchange_energy : t -> float 
(** Exchange energy *)

val nocc : t -> int
(** Number of occupied MOs *)

val empty: hartree_fock_data
(** Empty data *)


val make :
  ?kind:hartree_fock_kind ->
  ?guess:[ `Hcore | `Huckel | `Matrix of (ao,mo) Matrix.t ] ->
  ?max_scf:int ->
  ?level_shift:float -> ?threshold_SCF:float ->
  Simulation.t -> t


(** {1 Printers} *)

val pp : Format.formatter -> t -> unit

val pp_iterations : Format.formatter -> t -> unit

val pp_summary : Format.formatter -> t -> unit

