(* Type
 * 
 *    <<<~Bitstring.t~>>> *)

(* [[file:~/QCaml/common/bitstring.org::*Type][Type:1]] *)
type t
(* Type:1 ends here *)

(* General implementation *)


(* [[file:~/QCaml/common/bitstring.org::*General%20implementation][General implementation:1]] *)
val of_int : int -> t
val of_z   : Z.t -> t
val zero   : int -> t

val is_zero : t -> bool
val numbits : t -> int
val testbit : t -> int -> bool

val neg            : t -> t
val shift_left     : t -> int -> t
val shift_right    : t -> int -> t
val shift_left_one : int -> int -> t

val logor  : t -> t -> t
val logxor : t -> t -> t
val logand : t -> t -> t
val lognot : t -> t

val plus_one  : t -> t
val minus_one : t -> t

val hamdist        : t -> t -> int
val trailing_zeros : t -> int
val popcount       : t -> int

val to_list      : ?accu:(int list) -> t -> int list
val permutations : int -> int -> t list
(* General implementation:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/bitstring.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
