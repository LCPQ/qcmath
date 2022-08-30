(** Two electron integrals
*)

open Common
open Linear_algebra
open Gaussian
open Operators

open Constants
let cutoff = integrals_cutoff

module Bs  = Basis
module Cs  = Contracted_shell
module Csp = Contracted_shell_pair
module Cspc = Contracted_shell_pair_couple
module Fis = Four_idx_storage

module type Two_ei_structure =
  sig
    val name : string
    val class_of_contracted_shell_pair_couple :
      ?operator:Operator.t -> Cspc.t -> float Zmap.t
  end


module Make(T : Two_ei_structure) = struct

  include Four_idx_storage
  type t = Basis.t Four_idx_storage.t

  let class_of_contracted_shell_pair_couple = T.class_of_contracted_shell_pair_couple 

  let store_class ?(cutoff=integrals_cutoff) data contracted_shell_pair_couple cls = 
    let to_powers x = 
      let open Zkey in
      match to_powers x with
      | Three x -> x
      | _ -> assert false
    in

    let shell_p = Cspc.shell_pair_p contracted_shell_pair_couple
    and shell_q = Cspc.shell_pair_q contracted_shell_pair_couple
    in

    Array.iteri (fun i_c powers_i ->
        let i_c = Cs.index (Csp.shell_a shell_p) + i_c + 1 in
        let xi = to_powers powers_i in
        Array.iteri (fun j_c powers_j ->
            let j_c = Cs.index (Csp.shell_b shell_p) + j_c + 1 in
            let xj = to_powers powers_j in
            Array.iteri (fun k_c powers_k ->
                let k_c = Cs.index (Csp.shell_a shell_q) + k_c + 1 in 
                let xk = to_powers powers_k in
                Array.iteri (fun l_c powers_l ->
                    let l_c = Cs.index (Csp.shell_b shell_q) + l_c + 1 in
                    let xl = to_powers powers_l in
                    let key = Zkey.of_powers_twelve  xi xj xk xl in
                    let value = Zmap.find cls key in
                    if abs_float value > cutoff then
                      set_chem data i_c j_c k_c l_c value
                  ) (Cs.zkey_array (Csp.shell_b shell_q))
              ) (Cs.zkey_array (Csp.shell_a shell_q))
          ) (Cs.zkey_array (Csp.shell_b shell_p))
      ) (Cs.zkey_array (Csp.shell_a shell_p))







  let of_basis ?operator basis = 

    let n = Bs.size basis
    and shell = Bs.contracted_shells basis
    in

    let eri_array = 
      Fis.create ~size:n `Dense
    (*
      Fis.create ~size:n `Sparse
    *)
    in


    let t0 = Unix.gettimeofday () in

    let shell_pairs =
      Csp.of_contracted_shell_array shell
    in

    Printf.printf "%d significant shell pairs computed in %f seconds\n"
      (List.length shell_pairs) (Unix.gettimeofday () -. t0);

    let ishell = ref max_int in



    let t0 = Unix.gettimeofday () in

    let f shell_p =
      let () = 
(*
        if Parallel.rank < 2 && Cs.index (Csp.shell_a shell_p) < !ishell then
*)
        if Cs.index (Csp.shell_a shell_p) < !ishell then
          (ishell := Cs.index (Csp.shell_a shell_p) ; print_int !ishell ; print_newline ())
      in

      let sp =
        Csp.shell_pairs shell_p
      in

      try
          List.iter (fun shell_q ->
              let () = 
                if  Cs.index (Csp.shell_a shell_q) >
                    Cs.index (Csp.shell_a shell_p) then
                  raise Exit
              in
              let sq = Csp.shell_pairs shell_q in
              let cspc = 
                if Array.length sp < Array.length sq then
                  Cspc.make ~cutoff shell_p shell_q
                else
                  Cspc.make ~cutoff shell_q shell_p
              in

              match cspc with
              | Some cspc ->
                let cls =
                  class_of_contracted_shell_pair_couple ?operator cspc
                in
                store_class ~cutoff eri_array cspc cls
              | None -> ()
            ) shell_pairs;
        with Exit -> ()
    in

    (*
    List.rev shell_pairs
    *)
    shell_pairs
    (*
    |> Parallel.list_iter f ;
     *)
    |> List.iter f;
    Printf.printf "Computed %s Integrals in parallel in %f seconds\n%!"
      T.name (Unix.gettimeofday () -. t0);
    eri_array


end



