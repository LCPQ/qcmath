(* Type
 * 
 *    <<<~Charge.t~>>> *)

(* [[file:~/QCaml/common/charge.org::*Type][Type:1]] *)
type t
(* Type:1 ends here *)

(* Conversions *)


(* [[file:~/QCaml/common/charge.org::*Conversions][Conversions:1]] *)
val of_float : float -> t
val to_float : t -> float

val of_int   : int -> t
val to_int   : t -> int

val of_string: string -> t
val to_string: t -> string
(* Conversions:1 ends here *)

(* Simple operations *)


(* [[file:~/QCaml/common/charge.org::*Simple%20operations][Simple operations:1]] *)
val ( + ) : t -> t -> t
val ( - ) : t -> t -> t
val ( * ) : t -> float -> t
val ( / ) : t -> float -> t 
val is_null : t -> bool
(* Simple operations:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/charge.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
