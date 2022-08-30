(** Screened Electron-electron repulsion integrals (Yukawa potential). Required for F12/r12. *)

open Common
open Gaussian
open Operators

module Csp  = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple

module T = struct

  let name = "Screened electron repulsion integrals"

  open Zero_m_parameters

  let zero_m z =
    let expo_pq_inv = z.expo_p_inv +. z.expo_q_inv in
    assert (expo_pq_inv <> 0.);

    let expo_G_inv, coef_G =
      let g = 
        match z.operator with
        | Some (Operator.F12 f) -> f.F12_operator.gaussian
        | _ -> assert false
      in
      g.Gaussian_operator.expo_g_inv,
      g.Gaussian_operator.coef_g
    in

    let expo_pq = 1. /. expo_pq_inv in
    let maxm = z.maxm in

    let result = Array.init (maxm+1) (fun _ -> 0.) in
    Util.array_range 0 (Array.length coef_G)
    |> Array.iter (fun i -> 
      let fG_inv = expo_pq_inv +. expo_G_inv.(i) in
      let fG = 1. /. fG_inv in
      let t =
        if z.norm_pq_sq > Constants.integrals_cutoff then
          z.norm_pq_sq *. (expo_pq -. fG)
          else 0.
      in
      let fm = Util.boys_function ~maxm t in

      let tmp_array =
        let result = Array.init (maxm+1) (fun _ -> 1.) in
        Util.array_range 1 maxm
        |> Array.iter (fun k -> result.(k) <- result.(k-1) *. expo_pq *. expo_G_inv.(i));
        result
      in

      let tmp_result = Array.init (maxm+1) (fun _ -> 0.) in
      let rec aux accu m = function
        | 0 -> tmp_result.(m) <- fm.(m) *. accu
        | j ->
          begin
            let f =
              Util.array_range 0 m
              |> Array.fold_left (fun v k -> 
                v +. (Util.binom_float m k) *. tmp_array.(k) *. fm.(k)) 0. 
            in
            tmp_result.(m) <- accu *. f;
            let new_accu = -. accu *. expo_pq in
            (aux [@tailcall]) new_accu (m+1) (j-1)
          end
      in
      let f =
        Constants.two_over_sq_pi *. (sqrt expo_pq) *. fG *.
        expo_G_inv.(i) *.  exp (-.fG *. z.norm_pq_sq)
      in
      aux f 0 maxm;
      Array.iteri (fun k v ->
        result.(k) <- result.(k) +. coef_G.(i) *. v
      ) tmp_result) ;
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

