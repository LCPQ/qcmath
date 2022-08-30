

(* This type should be used for all charges in the program (electrons, nuclei,...). *)


(* [[file:~/QCaml/common/charge.org::*Type][Type:2]] *)
type t = float
(* Type:2 ends here *)

(* [[file:~/QCaml/common/charge.org::*Conversions][Conversions:2]] *)
external of_float : float -> t = "%identity"
external to_float : t -> float = "%identity"

let of_int = float_of_int
let to_int = int_of_float

let of_string = float_of_string 

let to_string x = 
  if x >  0. then
    Printf.sprintf "+%f" x
  else if x < 0. then
    Printf.sprintf "%f" x
  else 
    "0.0"
(* Conversions:2 ends here *)

(* [[file:~/QCaml/common/charge.org::*Simple%20operations][Simple operations:2]] *)
let gen_op op =
  fun a b ->
  op (to_float a) (to_float b)
  |> of_float

let ( + ) = gen_op ( +. )
let ( - ) = gen_op ( -. )
let ( * ) = gen_op ( *. )
let ( / ) = gen_op ( /. )

let is_null t = t == 0.
(* Simple operations:2 ends here *)

(* [[file:~/QCaml/common/charge.org::*Printers][Printers:2]] *)
let pp ppf x = 
  Format.fprintf ppf "@[%s@]" (to_string x)
(* Printers:2 ends here *)
