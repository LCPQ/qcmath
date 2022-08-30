(** Two-electron integrals with an arbitrary operator, with a functorial interface            
    parameterized by the fundamental two-electron integrals. 

    {% $(00|00)^m = \int \int \phi_p(r1) \hat{O} \phi_q(r2) dr_1 dr_2 $ %} : Fundamental two-electron integral

*)

open Common
open Gaussian
open Linear_algebra
open Operators

module type Two_ei_structure =
  sig
val name : string
(** Name of the kind of integrals, for printing purposes. *)

val class_of_contracted_shell_pair_couple :
  ?operator:Operator.t -> Contracted_shell_pair_couple.t -> float Zmap.t
(** Returns an integral class from a couple of contracted shells.
    The results is stored in a Zmap.
*)
  end



module Make : functor (T : Two_ei_structure) -> 
    sig
      include module type of Four_idx_storage
      type t = Basis.t Four_idx_storage.t

      val of_basis : ?operator:Operator.t ->  Basis.t -> t
      (** Compute all ERI's for a given {!Basis.t}. *)

    end

