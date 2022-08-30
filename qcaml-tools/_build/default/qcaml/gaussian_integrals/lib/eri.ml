(** Electron-electron repulsion integrals *)

open Common
open Gaussian

module Csp = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple

module T = struct

  let name = "Electron repulsion integrals"

  open Zero_m_parameters

  let zero_m z =
    let expo_pq_inv = z.expo_p_inv +. z.expo_q_inv in
    assert (expo_pq_inv <> 0.);
    let expo_pq = 1. /. expo_pq_inv in
    let t =
      if z.norm_pq_sq > Constants.integrals_cutoff then
        z.norm_pq_sq *. expo_pq
        else 0.
    in
    let maxm = z.maxm in
    let result = Util.boys_function ~maxm t in
    let rec aux accu k = function
      | 0 -> result.(k) <- result.(k) *. accu
      | l -> 
        begin
          result.(k) <- result.(k) *. accu;
          let new_accu = -. accu *. expo_pq in
          (aux [@tailcall]) new_accu (k+1) (l-1)
        end
    in
    let f = Constants.two_over_sq_pi *. (sqrt expo_pq) in
    aux f 0 maxm;
    result

  let class_of_contracted_shell_pair_couple ?operator shell_pair_couple = 
    assert (operator = None);
    let shell_p = Cspc.shell_pair_p shell_pair_couple
    and shell_q = Cspc.shell_pair_q shell_pair_couple                                         
    in
    if Array.length (Csp.shell_pairs shell_p) +
       (Array.length (Csp.shell_pairs shell_q))  < 4 then
      Two_electron_rr.contracted_class_shell_pair_couple
        ~zero_m shell_pair_couple
    else
      Two_electron_rr_vectorized.contracted_class_shell_pairs
        ~zero_m shell_p shell_q

end

module M = Two_electron_integrals.Make(T) 
include M

