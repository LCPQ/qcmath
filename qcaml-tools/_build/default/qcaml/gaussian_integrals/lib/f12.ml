(** Two electron integral functor for operators that are separable among %{ $(x,y,z)$ %}.
    It is parameterized by the [zero_m] function.
*)

open Common
open Operators

open Constants
let cutoff = integrals_cutoff

module T = struct

  let name = "F12"

  let class_of_contracted_shell_pair_couple ?operator shell_pair_couple = 
    let g = 
      match operator with
      | Some (Operator.F12 f) -> f.gaussian
      | _ -> failwith "Expected F12 operator"
    in
    F12_rr.contracted_class_shell_pair_couple 
      g.Gaussian_operator.expo_g_inv
      g.Gaussian_operator.coef_g
      shell_pair_couple

end

module M = Two_electron_integrals.Make(T)
include M



