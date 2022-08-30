(** Long-range electron-electron repulsion integrals.
    See Eq(52) in 10.1039/b605188j
*)

open Common
open Gaussian
open Operators

module Csp  = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple

module T = struct

  let name = "Long-range electron repulsion integrals"

  open Zero_m_parameters

  let zero_m z =
    let mu_erf = 
      match z.operator with
      | Some (Operator.Range_sep mu) -> mu
      | _ -> assert false
    in
    let m = mu_erf *. mu_erf in
    let expo_pq_inv = z.expo_p_inv +. z.expo_q_inv in
    let fG_inv = expo_pq_inv +. 1. /. m in
    let fG = 1. /. fG_inv in
    assert (expo_pq_inv <> 0.);
    let t =
      if z.norm_pq_sq > Constants.integrals_cutoff then
        z.norm_pq_sq *. fG
        else 0.
    in
    let maxm = z.maxm in
    let result = Util.boys_function ~maxm t in
    let rec aux accu k = function
      | 0 -> result.(k) <- result.(k) *. accu
      | l -> 
        begin
          result.(k) <- result.(k) *. accu;
          let new_accu = -. accu *. fG in
          (aux [@tailcall]) new_accu (k+1) (l-1)
        end
    in
    let f = Constants.two_over_sq_pi *. (sqrt fG) in
    aux f 0 maxm;
    result

  let class_of_contracted_shell_pair_couple ?operator shell_pair_couple = 
    let shell_p = Cspc.shell_pair_p shell_pair_couple
    and shell_q = Cspc.shell_pair_q shell_pair_couple                                         
    in
    if Array.length (Csp.shell_pairs shell_p) +
       (Array.length (Csp.shell_pairs shell_q))  < 4 then
      Two_electron_rr.contracted_class_shell_pair_couple
        ?operator ~zero_m shell_pair_couple
    else
      Two_electron_rr_vectorized.contracted_class_shell_pairs
        ?operator ~zero_m shell_p shell_q

end

module M = Two_electron_integrals.Make(T) 
include M

