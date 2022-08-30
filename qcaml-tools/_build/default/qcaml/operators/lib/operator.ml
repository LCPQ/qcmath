type t =
  | F12       of F12_operator.t
  | Gaussian  of Gaussian_operator.t
  | Range_sep of Rs_operator.t

let of_f12 f = F12 f
let of_gaussian g = Gaussian g
let of_range_separation mu = Range_sep mu

