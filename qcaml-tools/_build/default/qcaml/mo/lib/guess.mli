open Linear_algebra

(** Guess for Hartree-Fock calculations. *)

type ao = Ao.Ao_dim.t
type mo = Mo_dim.t

type guess =
| Hcore  of (ao,ao) Matrix.t (* Core Hamiltonian Matrix *)
| Huckel of (ao,ao) Matrix.t (* Huckel Hamiltonian Matrix *)
| Matrix of (ao,mo) Matrix.t (* Guess Eigenvectors *)

type t = guess


val make :
  ?nocc:int ->
  guess:[ `Hcore | `Huckel | `Matrix of (ao,mo) Matrix.t ] ->
  Ao.Basis.t -> t

