(* Type
 * 
 *    <<<~Powers.t~>>> *)

(* [[file:~/QCaml/common/powers.org::*Type][Type:1]] *)
type t = private {
  x   : int ;
  y   : int ;
  z   : int ;
  tot : int ;
}
(* Type:1 ends here *)

(* Conversions *)


(* [[file:~/QCaml/common/powers.org::*Conversions][Conversions:1]] *)
val of_int_tuple : int * int * int -> t
val to_int_tuple : t -> int * int * int
(* Conversions:1 ends here *)

(* Operations *)


(* [[file:~/QCaml/common/powers.org::*Operations][Operations:1]] *)
val get  : Coordinate.axis -> t -> int
val incr : Coordinate.axis -> t -> t
val decr : Coordinate.axis -> t -> t
(* Operations:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/powers.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
