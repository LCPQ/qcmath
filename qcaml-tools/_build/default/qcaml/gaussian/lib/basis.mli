(** The atomic basis set is represented as an array of {!ContractedShell.t}. *)

type t 

open Particles

val of_nuclei_and_general_basis : Nuclei.t -> General_basis.t -> t
(** Takes an array of {!Nuclei.t}, and a {!GeneralBasis.t} (such as cc-pVDZ
  for instance) and creates the corresponding atomic basis set.
  All the {!Element.t}'s of the array of {!Nuclei.t} are searched in 
  the {!GeneralBasis.t}, and the basis is built by creating
  {!ContractedShell.t}'s centered on the nuclei with the exponents
  and contraction coefficients given by the {!GeneralBasis.t}.
*)


val of_nuclei_and_basis_filename : nuclei:Nuclei.t -> string -> t
(** Same as {!of_nuclei_and_general_basis}, but taking the {!GeneralBasis.t}
  from a file. 
  *)

val of_nuclei_and_basis_string : nuclei:Nuclei.t -> string -> t
(** Same as {!of_nuclei_and_general_basis}, but taking the {!GeneralBasis.t}
  from a string. 
  *)

val of_nuclei_and_basis_filenames : nuclei:Nuclei.t -> string list -> t
(** Same as {!of_nuclei_and_general_basis}, but taking the {!GeneralBasis.t}
  from multiple files. 
  *)


val size : t -> int
(** Number of contracted basis functions. *)

val atomic_shells : t -> Atomic_shell.t array
(** Returns the contracted basis functions per atom. *)

val contracted_shells : t -> Contracted_shell.t array
(** Returns all the contracted basis functions. *)

val general_basis : t -> General_basis.t
(** Returns the [!GeneralBasis] that was used to build the current basis. *)

(** {2 Printers} *)

val to_string : t -> string
(** Pretty prints the basis set in a string. TODO *)

val pp : Format.formatter -> t -> unit

