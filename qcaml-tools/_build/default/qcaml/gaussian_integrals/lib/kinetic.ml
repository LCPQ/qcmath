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
module Ps  = Primitive_shell

type t = (Basis.t, Basis.t) Matrix.t

let cutoff = integrals_cutoff

let to_powers x =
  let open Zkey in
  match to_powers x with
  | Six x -> x
  | _ -> assert false

(** Computes all the kinetic integrals of the contracted shell pair *)
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

      let sp = Csp.shell_pairs shell_p in
      for ab=0 to (Array.length sp - 1)
      do
        let coef_prod =
          (Csp.coefficients shell_p).(ab)
        in
        (* Screening on thr product of coefficients *)
        if (abs_float coef_prod) > 1.e-4*.cutoff then
          begin
            let center_pa =
              Psp.center_minus_a sp.(ab)
            in
            let expo_inv =
              (Csp.exponents_inv shell_p).(ab)
            in
            let expo_a =
              Ps.exponent (Psp.shell_a sp.(ab))
            and expo_b =
              Ps.exponent (Psp.shell_b sp.(ab))
            in

            let xyz_of_int k =
              match k with
              | 0 -> Co.X
              | 1 -> Co.Y
              | _ -> Co.Z
            in
            Array.iteri (fun i key ->
                let (angMomA,angMomB) = to_powers key in
                let ov a b k =
                  let xyz = xyz_of_int k in
                  Overlap_primitives.hvrr (a, b)
                    expo_inv
                    (Co.get xyz a_minus_b,
                    Co.get xyz center_pa)
                in
                let f k =
                  let xyz = xyz_of_int k in
                  ov (Po.get xyz angMomA) (Po.get xyz angMomB) k
                and g k =
                  let xyz = xyz_of_int k in
                  let s1 = ov (Po.get xyz angMomA - 1) (Po.get xyz angMomB - 1) k
                  and s2 = ov (Po.get xyz angMomA + 1) (Po.get xyz angMomB - 1) k
                  and s3 = ov (Po.get xyz angMomA - 1) (Po.get xyz angMomB + 1) k
                  and s4 = ov (Po.get xyz angMomA + 1) (Po.get xyz angMomB + 1) k
                  and a = float_of_int_fast (Po.get xyz angMomA)
                  and b = float_of_int_fast (Po.get xyz angMomB)
                  in
                  0.5 *. a *. b *. s1 -. expo_a *. b *. s2 -. expo_b *. a *. s3 +.
                    2.0 *. expo_a *. expo_b *. s4
                in
                let s = Array.init 3 f
                and k = Array.init 3 g
                in
                let norm =  norm_coef_scales.(i) in
                let integral = chop norm (fun () ->
                    k.(0)*.s.(1)*.s.(2) +.
                    s.(0)*.k.(1)*.s.(2) +.
                    s.(0)*.s.(1)*.k.(2)
                  ) in
                contracted_class.(i) <- contracted_class.(i) +. coef_prod *. integral
              ) class_indices
          end
      done;

      let result =
        Zmap.create (Array.length contracted_class)
      in
      Array.iteri (fun i key -> Zmap.add result key contracted_class.(i)) class_indices;
      result
    end


(** Create kinetic energy matrix *)
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

let of_basis_pair _first_basis _second_basis =
  failwith "Not implemented"

