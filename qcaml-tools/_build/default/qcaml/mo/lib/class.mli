(** Classes of MOs : active, inactive, etc *)

type mo_class =
  | Core      of int  (* Always doubly occupied *)
  | Inactive  of int  (* With 0,1 or 2 holes *)
  | Active    of int  (* With 0,1 or 2 holes or particles *)
  | Virtual   of int  (* With 0,1 or 2 particles *)
  | Deleted   of int  (* Always unoccupied *)
  | Auxiliary of int  (* Function of the auxiliary basis set *)

type t

(** Creation *)
val of_list : mo_class list -> t

val to_list : t -> mo_class list

val fci : frozen_core:Frozen_core.t -> Basis.t -> t
(** Creates the MO classes for FCI calculations : all [Active]. The 
    [n] lowest MOs are [Core] if [frozen_core = true].
*)

val cas_sd: Basis.t -> frozen_core:Frozen_core.t -> int -> int -> t
(** [cas_sd mo_basis n m ] creates the MO classes for CAS(n,m) + SD
    calculations.  lowest MOs are [Core], then all the next MOs are [Inactive],
    then [Active], then [Virtual].
*)


val core_mos : t -> int list
(** Returns a list containing the indices of the core MOs. *)

val active_mos : t -> int list
(** Returns a list containing the indices of the active MOs. *)

val virtual_mos : t -> int list
(** Returns a list containing the indices of the virtual MOs. *)

val inactive_mos : t -> int list
(** Returns a list containing the indices of the inactive MOs. *)

val deleted_mos : t -> int list
(** Returns a list containing the indices of the deleted MOs. *)

val auxiliary_mos : t -> int list
(** Returns a list containing the indices of the auxiliary MOs. *)

val mo_class_array : t -> mo_class array
(** Returns an array [a] such that [a.(i)] returns the class of MO [i].
    As the MO indices start from [1], the array has an extra zero entry
    that should be ignored. *)

(** {2 Printers} *)

val pp_mo_class : Format.formatter -> mo_class -> unit

val pp : Format.formatter -> t -> unit

