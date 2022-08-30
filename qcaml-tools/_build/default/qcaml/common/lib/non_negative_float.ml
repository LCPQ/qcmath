(* [[file:~/QCaml/common/non_negative_float.org::*Type][Type:2]] *)
type t = float
(* Type:2 ends here *)



(* The ~of_float~ function checks that the float is non-negative.
 * The unsafe variant doesn't do this check. *)


(* [[file:~/QCaml/common/non_negative_float.org::*Conversions][Conversions:2]] *)
let of_float x =
  if x < 0. then invalid_arg (__FILE__^": of_float");
  x

external to_float        : t -> float = "%identity"
external unsafe_of_float : float -> t = "%identity"

let to_string x =
  let f = to_float x in string_of_float f

let of_string x =
 let f = float_of_string x in of_float f
(* Conversions:2 ends here *)
