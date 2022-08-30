open Common
open Linear_algebra
open Gaussian
open Util
open Constants

module Am  = Angular_momentum
module Bs  = Basis
module Co  = Coordinate
module Cs  = Contracted_shell
module Csp = Contracted_shell_pair
module Po  = Powers
module Psp = Primitive_shell_pair

type t = (Basis.t, Basis.t) Matrix.t

let cutoff = integrals_cutoff

let to_powers x =
  let open Zkey in
  match to_powers x with
  | Six x -> x
  | _ -> assert false

(** Computes all the overlap integrals of the contracted shell pair *)
let contracted_class shell_a shell_b : float Zmap.t =

  match Csp.make shell_a shell_b with
  | None -> Zmap.create 0
  | Some shell_p ->
    begin

      (* Pre-computation of integral class indices *)
      let class_indices = Csp.zkey_array shell_p in

      let contracted_class =
        Array.make (Array.length class_indices) 0.
      in

      let a_minus_b =
        Csp.a_minus_b shell_p
      in
      let norm_coef_scales =
        Csp.norm_scales shell_p
      in

      (* Compute all integrals in the shell for each pair of significant shell pairs *)

      let xyz_of_int k =
        match k with
        | 0 -> Co.X
        | 1 -> Co.Y
        | _ -> Co.Z
      in

      List.iter (fun (coef_prod, psp) ->
          (* Screening on the product of coefficients *)
          if (abs_float coef_prod) > 1.e-6*.cutoff then
            begin
              let expo_inv = Psp.exponent_inv psp
              and center_pa = Psp.center_minus_a psp
              in

              Array.iteri (fun i key ->
                  let (angMomA,angMomB) = to_powers key in
                  let f k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b,
                      Co.get xyz center_pa)
                  in
                  let norm =  norm_coef_scales.(i) in
                  let integral = chop norm (fun () -> (f 0)*.(f 1)*.(f 2)) in
                  contracted_class.(i) <- contracted_class.(i) +. coef_prod *. integral
                ) class_indices
            end
        ) (Csp.coefs_and_shell_pairs shell_p);

      let result =
        Zmap.create (Array.length contracted_class)
      in
      Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
      result
    end


(** Create overlap matrix *)
let of_basis basis =
  let to_powers x =
    let open Zkey in
    match to_powers x with
    | Three x -> x
    | _ -> assert false
  in

  let n     = Bs.size basis
  and shell = Bs.contracted_shells basis
  in

  let result = Matrix.create n n in
  for j=0 to (Array.length shell) - 1 do
    for i=0 to j do
      (* Compute all the integrals of the class *)
      let cls =
        contracted_class shell.(i) shell.(j)
      in

      Array.iteri (fun j_c powers_j ->
          let j_c = Cs.index shell.(j) + j_c + 1 in
          let xj = to_powers powers_j in
          Array.iteri (fun i_c powers_i ->
              let i_c = Cs.index shell.(i) + i_c + 1 in
              let xi = to_powers powers_i in
              let key =
                Zkey.of_powers_six xi xj
              in
              let value =
                try Zmap.find cls key
                with Not_found -> 0.
              in
              Matrix.set result i_c j_c value;
              Matrix.set result j_c i_c value;
            ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(i))))
        ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(j))))
    done;
  done;
  Matrix.detri_inplace result;
  result


(** Create mixed overlap matrix *)
let of_basis_pair first_basis second_basis =
  let to_powers x =
    let open Zkey in
    match to_powers x with
    | Three x -> x
    | _ -> assert false
  in

  let n      = Bs.size first_basis
  and m      = Bs.size second_basis
  and first  = Bs.contracted_shells first_basis
  and second = Bs.contracted_shells second_basis
  in

  let result = Matrix.create n m in
  for j=0 to (Array.length second) - 1 do
    for i=0 to  (Array.length first) - 1 do
      (* Compute all the integrals of the class *)
      let cls =
        contracted_class first.(i) second.(j)
      in

      Array.iteri (fun j_c powers_j ->
          let j_c = Cs.index second.(j) + j_c + 1 in
          let xj = to_powers powers_j in
          Array.iteri (fun i_c powers_i ->
              let i_c = Cs.index first.(i) + i_c + 1 in
              let xi = to_powers powers_i in
              let key =
                Zkey.of_powers_six xi xj
              in
              let value =
                try Zmap.find cls key
                with Not_found -> 0.
              in
              Matrix.set result i_c j_c value;
            ) (Am.zkey_array (Singlet (Cs.ang_mom first.(i))))
        ) (Am.zkey_array (Singlet (Cs.ang_mom second.(j))))
    done;
  done;
  result



