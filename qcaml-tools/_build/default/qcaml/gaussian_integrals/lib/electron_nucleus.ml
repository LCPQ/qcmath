(** Electron-nucleus repulsion integrals *)

include Common
include Particles
include Linear_algebra
include Gaussian
open Util
open Constants

module Am = Angular_momentum
module Bs = Basis
module Cs = Contracted_shell

type t = (Bs.t, Bs.t) Matrix.t

(** (0|0)^m : Fundamental electron-nucleus repulsion integral
    $ \int \phi_p(r1) 1/r_{C} dr_1 $

    maxm        : Maximum total angular momentum
    expo_pq_inv : $1./p + 1./q$ where $p$ and $q$ are the exponents of
                $\phi_p$ and $\phi_q$
    norm_pq_sq  : square of the distance between the centers of $\phi_p$
                and $\phi_q$
*)

let zero_m ~maxm ~expo_pq_inv ~norm_pq_sq =
  let exp_pq = 1. /. expo_pq_inv in
  let t = norm_pq_sq *. exp_pq in
  boys_function ~maxm t
  |> Array.mapi (fun m fm ->
      two_over_sq_pi *. fm *.
      (pow exp_pq m) *. (sqrt exp_pq)
    )


(** Compute all the integrals of a contracted class *)
let contracted_class_shell_pair shell_p geometry: float Zmap.t =
  One_electron_rr.contracted_class_shell_pair ~zero_m shell_p geometry


let of_basis_nuclei ~basis nuclei =
  let to_powers x = 
    let open Zkey in
    match to_powers x with
    | Three x -> x
    | _ -> assert false
  in

  let n     = Bs.size basis
  and shell = Bs.contracted_shells basis
  in

  let eni_array = Matrix.create n n in

  (* Pre-compute all shell pairs *)
  let shell_pairs =
    Array.mapi (fun i shell_a -> Array.map (fun shell_b -> 
        Contracted_shell_pair.make shell_a shell_b) (Array.sub shell 0 (i+1)) ) shell
  in

  (* Compute Integrals *)
  for i=0 to (Array.length shell) - 1 do
    for j=0 to i do
      match shell_pairs.(i).(j) with
      | None -> ()
      | Some shell_p ->
        (* Compute all the integrals of the class *)
        let cls =
          contracted_class_shell_pair shell_p nuclei
        in

        (* Write the data in the output file *)
        Array.iteri (fun i_c powers_i ->
            let i_c = Cs.index shell.(i) + i_c + 1 in
            let xi = to_powers powers_i in
            Array.iteri (fun j_c powers_j ->
                let j_c = Cs.index shell.(j) + j_c + 1 in
                let xj = to_powers powers_j in
                let key = 
                  Zkey.of_powers_six xi xj
                in
                let value = 
                  Zmap.find cls key 
                in
                Matrix.set eni_array j_c i_c value;
                Matrix.set eni_array i_c j_c value;
              ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(j))))
          ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(i))))
    done;
  done;
  Matrix.detri_inplace eni_array;
  eni_array

let of_basis _basis =
  invalid_arg "of_basis_nuclei should be called for NucInt"

let of_basis_pair _basis =
  failwith "Not implemented"

