(* Type
 * 
 *    <<<~Non_negative_float.t~>> *)

(* [[file:~/QCaml/common/non_negative_float.org::*Type][Type:1]] *)
type t = private float
(* Type:1 ends here *)

(* Conversions *)


(* [[file:~/QCaml/common/non_negative_float.org::*Conversions][Conversions:1]] *)
val of_float        : float -> t
val unsafe_of_float : float -> t
val to_float        : t -> float

val of_string       : string -> t
val to_string       : t -> string
(* Conversions:1 ends here *)
