(** Signature for matrices built on the {!Basis.t} *)

open Gaussian
open Linear_algebra

type t = (Basis.t, Basis.t) Matrix.t

val of_basis : Basis.t -> t
(** Build from a {!Basis.t}. *)

val of_basis_pair : Basis.t -> Basis.t -> t
(** Build from a pair of {!Basis.t}. *)
