(* [[file:~/QCaml/common/util.org::*Erf][Erf:2]] *)
external erf_float : float -> float
  = "erf_float_bytecode" "erf_float" [@@unboxed] [@@noalloc]
(* Erf:2 ends here *)

(* [[file:~/QCaml/common/util.org::*Erfc][Erfc:2]] *)
external erfc_float : float -> float
  = "erfc_float_bytecode" "erfc_float" [@@unboxed] [@@noalloc]
(* Erfc:2 ends here *)

(* [[file:~/QCaml/common/util.org::*Gamma][Gamma:2]] *)
external gamma_float : float -> float
  = "gamma_float_bytecode" "gamma_float" [@@unboxed] [@@noalloc]
(* Gamma:2 ends here *)

(* [[file:~/QCaml/common/util.org::*Popcnt][Popcnt:2]] *)
val popcnt : int64 -> int
(* Popcnt:2 ends here *)

(* [[file:~/QCaml/common/util.org::*Trailz][Trailz:2]] *)
val trailz : int64 -> int
(* Trailz:2 ends here *)

(* [[file:~/QCaml/common/util.org::*Leadz][Leadz:2]] *)
val leadz : int64 -> int
(* Leadz:2 ends here *)

(* General functions *)


(* [[file:~/QCaml/common/util.org::*General%20functions][General functions:1]] *)
val fact : int -> float
(* @raise Invalid_argument for negative arguments or arguments >100. *)
val binom       : int -> int -> int
val binom_float : int -> int -> float

val chop              : float -> (unit -> float) -> float
val pow               : float -> int -> float
val float_of_int_fast : int -> float

val of_some : 'a option -> 'a

exception Not_implemented of string
val not_implemented : string -> 'a
(* @raise Not_implemented. *)
(* General functions:1 ends here *)

(* Functions related to the Boys function *)


(* [[file:~/QCaml/common/util.org::*Functions%20related%20to%20the%20Boys%20function][Functions related to the Boys function:1]] *)
val incomplete_gamma : alpha:float -> float -> float
(* @raise Failure when the calculation doesn't converge. *)
(* Functions related to the Boys function:1 ends here *)

(* [[file:~/QCaml/common/util.org::*Functions%20related%20to%20the%20Boys%20function][Functions related to the Boys function:3]] *)
val boys_function : maxm:int -> float -> float array
(* Functions related to the Boys function:3 ends here *)

(* List functions *)
   

(* [[file:~/QCaml/common/util.org::*List%20functions][List functions:1]] *)
val list_some  : 'a option list -> 'a list
val list_range : int -> int -> int list
val list_pack  : int -> 'a list -> 'a list list
(* List functions:1 ends here *)

(* Array functions *)
   

(* [[file:~/QCaml/common/util.org::*Array%20functions][Array functions:1]] *)
val array_range   : int -> int -> int array
val array_sum     : float array -> float
val array_product : float array -> float
(* Array functions:1 ends here *)

(* Stream functions *)
   

(* [[file:~/QCaml/common/util.org::*Stream%20functions][Stream functions:1]] *)
val stream_range   : int -> int -> int Stream.t
val stream_to_list : 'a Stream.t -> 'a list
val stream_fold    : ('a -> 'b -> 'a) -> 'a -> 'b Stream.t -> 'a
(* Stream functions:1 ends here *)

(* Printers *)


(* [[file:~/QCaml/common/util.org::*Printers][Printers:1]] *)
val pp_float_array_size   : Format.formatter -> float array -> unit
val pp_float_array        : Format.formatter -> float array -> unit
val pp_float_2darray_size : Format.formatter -> float array array -> unit
val pp_float_2darray      : Format.formatter -> float array array -> unit
val pp_bitstring          : int -> Format.formatter -> Z.t -> unit
(* Printers:1 ends here *)
