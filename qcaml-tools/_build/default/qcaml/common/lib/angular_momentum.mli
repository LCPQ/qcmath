(* Type
 * 
 *    <<<~Angular_momentum.t~>>>
 *    #+NAME: types *)

(* [[file:~/QCaml/common/angular_momentum.org::types][types]] *)
type t =
  | S | P | D | F | G | H | I | J | K | L | M | N | O
  | Int of int

exception Angular_momentum_error of string

type kind =
    Singlet of t
  | Doublet of (t * t)
  | Triplet of (t * t * t)
  | Quartet of (t * t * t * t)
(* types ends here *)

(* Conversions *)


(* [[file:~/QCaml/common/angular_momentum.org::*Conversions][Conversions:1]] *)
val of_char : char -> t
val to_char : t -> char

val to_int : t -> int
val of_int : int -> t

val to_string : t -> string
(* Conversions:1 ends here *)

(* Shell functions *)


(* [[file:~/QCaml/common/angular_momentum.org::*Shell functions][Shell functions:1]] *)
val n_functions : t -> int
val zkey_array  : kind -> Zkey.t array
(* Shell functions:1 ends here *)

(* Arithmetic *)


(* [[file:~/QCaml/common/angular_momentum.org::*Arithmetic][Arithmetic:1]] *)
val ( + ) : t -> t -> t
val ( - ) : t -> t -> t
(* Arithmetic:1 ends here *)

(* Printers
 * 
 *    Printers can print as a string (default) or as an integer. *)


(* [[file:~/QCaml/common/angular_momentum.org::*Printers][Printers:1]] *)
val pp        : Format.formatter -> t -> unit
val pp_string : Format.formatter -> t -> unit
val pp_int    : Format.formatter -> t -> unit
(* Printers:1 ends here *)
