(** Type for the Fock operator in AO basis. *)

open Linear_algebra

type t 
type ao = Ao.Ao_dim.t

(** {1 Accessors} *)

val fock : t -> (ao,ao) Matrix.t
(** Fock matrix in AO basis *)

val core : t -> (ao,ao) Matrix.t
(** Core Hamiltonian : {% $\langle i | \hat{h} | j \rangle$ %} *)

val coulomb : t -> (ao,ao) Matrix.t
(** Coulomb matrix : {% $\langle i | J | j \rangle$ %} *)

val exchange : t -> (ao,ao) Matrix.t
(** Exchange matrix : {% $\langle i | K | j \rangle$ %} *)


(** {1 Creators} *)

val make_rhf : density:(ao,ao) Matrix.t -> ?threshold:float -> Ao.Basis.t -> t
(** Create a Fock operator in the RHF formalism. Expected density is
    {% $2 \mathbf{C\, C}^\dagger$ %}. [threshold] is a threshold on the
    integrals. *)

val make_uhf :
  density_same:(ao,ao) Matrix.t ->
  density_other:(ao,ao) Matrix.t ->
  ?threshold:float ->
  Ao.Basis.t -> t
(** Create a Fock operator in the UHF formalism. Expected density is
    {% $\mathbf{C\, C}^\dagger$ %}. When building the {% $\alpha$ %} Fock
    operator, [density_same] is the {% $\alpha$ %} density and [density_other]
    is the {% $\beta$ %} density. [threshold] is a threshold on the integrals. *)


(** {1 Operations} *)

val add : t -> t -> t
(** Add two Fock operators sharing the same core Hamiltonian. *)

val sub : t -> t -> t
(** Subtract two Fock operators sharing the same core Hamiltonian. *)

val scale : float -> t -> t
(** Scale the Fock matrix by a constant *)

(** {1 Printers} *)

val pp : Format.formatter -> t -> unit
