(* Type
 * 
 *    <<<~Range.t~>>> *)

(* [[file:~/QCaml/common/range.org::*Type][Type:1]] *)
type t
(* Type:1 ends here *)

(* Conversion *)


(* [[file:~/QCaml/common/range.org::*Conversion][Conversion:1]] *)
val of_string   : string -> t
val to_string   : t -> string
val to_int_list : t -> int list
(* Conversion:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/range.org::*Printers][Printers:1]] *)
val pp : Format.formatter -> t -> unit
(* Printers:1 ends here *)
