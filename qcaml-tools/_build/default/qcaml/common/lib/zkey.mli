(* Types
 * 
 *    <<<~Zkey.t~>>> *)

(* [[file:~/QCaml/common/zkey.org::*Types][Types:1]] *)
type t 

type kind =
  | Three  of  Powers.t
  | Four   of (int * int * int * int)
  | Six    of (Powers.t * Powers.t)
  | Nine   of (Powers.t * Powers.t * Powers.t)
  | Twelve of (Powers.t * Powers.t * Powers.t * Powers.t)
(* Types:1 ends here *)

(* Conversions *)


(* [[file:~/QCaml/common/zkey.org::*Conversions][Conversions:1]] *)
val of_powers_three  : Powers.t -> t
val of_powers_six    : Powers.t -> Powers.t -> t
val of_powers_nine   : Powers.t -> Powers.t -> Powers.t -> t
val of_powers_twelve : Powers.t -> Powers.t -> Powers.t -> Powers.t -> t
val of_powers        : kind -> t
val of_int_array     : int array -> t
val of_int_four      : int -> int -> int -> int -> t
val to_int_array     : t -> int array
val to_powers        : t -> kind
val to_string        : t -> string
(* Conversions:1 ends here *)

(* Functions for hash tables *)


(* [[file:~/QCaml/common/zkey.org::*Functions%20for%20hash%20tables][Functions for hash tables:1]] *)
val hash    : t -> int
val equal   : t -> t -> bool
val compare : t -> t -> int
(* Functions for hash tables:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/zkey.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
