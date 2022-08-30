(** Storage for four-index data (integrals, density matrices, ...).

There are two kinds of ordering of indices:

- Physicist's : {% $\langle i j | k l \rangle$ %}
- Chemist's   : {% $(ij|kl)$ %}

*)

type 'a t

(** Element for the stream *)
type element =
{
  i_r1: int ;
  j_r2: int ;
  k_r1: int ;
  l_r2: int ;
  value: float
}

val create : size:int -> [< `Dense | `Sparse ] -> 'a t
(** If [`Dense] is chosen, internally the data is stored as a 4-dimensional
    [Bigarray]. Else, it is stored as a hash table.
*)

(** {2 Accessors} *)

val size : 'a t -> int
(** Number of stored elements *)
  
val get_chem : 'a t -> int -> int -> int -> int -> float
(** Get an integral using the Chemist's convention {% $(ij|kl)$ %}. *)

val get_phys : 'a t -> int -> int -> int -> int -> float
(** Get an integral using the Physicist's convention {% $\langle ij|kl \rangle$ %}. *)

val set_chem : 'a t -> int -> int -> int -> int -> float -> unit
(** Set an integral using the Chemist's convention {% $(ij|kl)$ %}. *)

val set_phys : 'a t -> int -> int -> int -> int -> float -> unit
(** Set an integral using the Physicist's convention {% $\langle ij|kl \rangle$ %}. *)

val increment_chem : 'a t -> int -> int -> int -> int -> float -> unit
(** Increments an integral using the Chemist's convention {% $(ij|kl)$ %}. *)

val increment_phys : 'a t -> int -> int -> int -> int -> float -> unit
(** Increments an integral using the Physicist's convention {% $\langle ij|kl \rangle$ %}. *)

val get_chem_all_i : 'a t -> j:int -> k:int -> l:int -> 'a Vector.t
(** Get all integrals in an array [a.{i} =] {% $(\cdot j|kl)$ %} . *)

val get_phys_all_i : 'a t -> j:int -> k:int -> l:int -> 'a Vector.t
(** Get all integrals in an array [a.{i} =] {% $\langle \cdot j|kl \rangle$ %} . *)

val get_chem_all_ij : 'a t -> k:int -> l:int -> ('a,'a) Matrix.t
(** Get all integrals in an array [a.{i,j} =] {% $(\cdot \cdot|kl)$ %} . *)

val get_phys_all_ij : 'a t -> k:int -> l:int -> ('a,'a) Matrix.t
(** Get all integrals in an array [a.{i,j} =] {% $\langle \cdot \cdot|kl \rangle$ %} . *)

val to_stream : 'a t -> element Stream.t
(** Retrun the data structure as a stream. *)

val to_list : 'a t -> element list
(** Retrun the data structure as a list. *)

val four_index_transform : ('a,'b) Matrix.t -> 'a t -> 'b t
(** Perform a four-index transformation *)

(** {2 I/O} *)

val to_file : ?cutoff:float -> filename:string -> 'a t -> unit
(** Write the data to file, using the physicist's ordering. *)

val of_file : size:int -> sparsity:[< `Dense | `Sparse ]
  -> Scanf.Scanning.file_name -> 'a t
(** Read from a text file with format ["%d %d %d %d %f"]. *)

val relabel : 'a t -> 'b t
