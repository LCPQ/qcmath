type t =
  | F12 of F12_operator.t
  | Gaussian of Gaussian_operator.t
  | Range_sep of Rs_operator.t

val of_f12 : F12_operator.t -> t
(** Creates a F12 operator *)

val of_gaussian: Gaussian_operator.t -> t
(** Creates a Gaussian operator *)

val of_range_separation: Rs_operator.t -> t
(** Creates a range-separated operator *)

