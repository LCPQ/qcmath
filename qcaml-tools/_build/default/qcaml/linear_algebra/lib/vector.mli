(** Vector module

This module encapsulates the [Vec] module of Lacaml, to facilitate the change of backend
in the future, or to easily implement distributed vectors.

The indexing of vectors is 1-based.
*)

open Lacaml.D

type 'a t
(* Parameter ['a] defines the basis on which the vector is expanded. *)

val relabel : 'a t -> 'b t

val dim : 'a t -> int
(** Returns the dimension of the vector *)

val add : 'a t -> 'a t -> 'a t
(** [c = add a b] : %{ $c = a + b$ %} *)

val sub : 'a t -> 'a t -> 'a t
(** [c = sub a b] : %{ $c = a - b$ %} *)

val mul : 'a t -> 'a t -> 'a t
(** [c = mul a b] : %{ $c_i = a_i \times b_i$ %} *)

val div : 'a t -> 'a t -> 'a t
(** [c = div a b] : %{ $c_i = a_i / b_i$ %} *)

val dot : 'a t -> 'a t -> float
(** [dot v1 v2] : Dot product between v1 and v2 *)

val norm : 'a t -> float
(** Norm of the vector : %{ ||v|| = $\sqrt{v.v}$ %} *)
  
val sqr  : 'a t -> 'a t
(** [sqr t = map (fun x -> x *. x) t] *)
  
val sqrt : 'a t -> 'a t
(** [sqrt t = map sqrt t] *)

val neg  : 'a t -> 'a t
(** [neg  t = map (f x -> -. x) t *)
  
val reci : 'a t -> 'a t
(** [reci t = map (f x -> 1./x) t *)
  
val abs  : 'a t -> 'a t
(** [abs  t = map (f x -> abs_float x) t *)
  
val cos  : 'a t -> 'a t
(** [cos  t = map (f x -> cos x) t *)
  
val sin  : 'a t -> 'a t
(** [sin  t = map (f x -> sin x) t *)
  
val tan  : 'a t -> 'a t
(** [tan  t = map (f x -> tan x) t *)
  
val acos  : 'a t -> 'a t
(** [acos  t = map (f x -> acos x) t *)

val asin  : 'a t -> 'a t
(** [asin  t = map (f x -> asin x) t *)
  
val atan  : 'a t -> 'a t
(** [atan  t = map (f x -> atan x) t *)
  
val amax : 'a t -> float
(** Maximum of the absolute values of the elements of the vector. *)

val normalize : 'a t -> 'a t
(** Returns the vector normalized *)

val init : int ->  (int -> float) -> 'a t 
(** Initialize the vector with a function taking the index as parameter.*)

val sum  : 'a t -> float
(** Returns the sum of the elements of the vector *)
  
val copy : ?n:int -> ?ofsy:int -> ?incy:int -> ?y:vec -> ?ofsx:int -> ?incx:int ->  'a t -> 'a t
(** Returns a copy of the vector X into Y. [ofs] controls the offset and [inc]
    the increment.  *)
  
val map  : (float -> float) -> 'a t -> 'a t
(** Equivalent to [Array.map] *)

val iter : (float -> unit) -> 'a t -> unit
(** Equivalent to [Array.iter] *)

val iteri : (int -> float -> unit) -> 'a t -> unit
(** Equivalent to [Array.iteri] *)

val of_array : float array -> 'a t
(** Converts an array of floats into a vector *)

val of_list : float list -> 'a t
(** Converts a list of floats into a vector *)

val to_array : 'a t -> float array
(** Converts to an array of floats *)

val to_list : 'a t -> float list
(** Converts to a list of floats *)

val create : int -> 'a t
(** Creates an uninitialized vector *)
                      
val make : int -> float -> 'a t
(** Creates a vector initialized with the given [float].*)
                      
val make0 : int -> 'a t
(** Creates a zero-initialized vector.*)
                      
val fold : ('a -> float -> 'a) -> 'a -> 'b t -> 'a
(** Equivalent to [Array.fold] *)

val random : ?rnd_state:Random.State.t -> ?from:float -> ?range:float -> int -> 'a t
(** Returns a vector of uniform random numbers %{ $ f \le u \le f+r $
 %} where [f] is [from] and [r] is [range].
 Default values: [from:-1.0] [range:2.0] *)

(*
val of_bigarray : (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array1.t -> 'a t
(** Builds by converting from a Fortran bigarray *)

val to_bigarray : 'a t -> (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array1.t
(** Converts the vector into a Fortran bigarray *)
*)

val of_bigarray_inplace : (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array1.t -> 'a t
(** Builds by converting from a Fortran bigarray *)

val to_bigarray_inplace : 'a t -> (float, Stdlib.Bigarray.float64_elt, Stdlib.Bigarray.fortran_layout) Stdlib.Bigarray.Array1.t
(** Converts the vector into a Fortran bigarray *)


val (%.) : 'a t -> int -> float
(** [t%.(i)] Returns the i-th element of the vector *)

val set : 'a t -> int -> float -> unit
(** Modifies the value in-place at the i-th position *)
  
