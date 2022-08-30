open Common
open Linear_algebra
open Gaussian
open Constants

type t = (Basis.t, Basis.t) Matrix.t array
(*
[| "x"; "y"; "z"; "x2"; "y2"; "z2" |]
*)

module Am  = Angular_momentum
module Bs  = Basis
module Co  = Coordinate
module Cs  = Contracted_shell
module Csp = Contracted_shell_pair
module Po  = Powers
module Psp = Primitive_shell_pair

let matrix t = function
  | "x" -> t.(0)
  | "y" -> t.(1)
  | "z" -> t.(2)
  | "x2" -> t.(3)
  | "y2" -> t.(4)
  | "z2" -> t.(5)
  | "xy" -> t.(6)
  | "xz" -> t.(8)
  | "yz" -> t.(7)
  | "x3" -> t.(9)
  | "y3" -> t.(10)
  | "z3" -> t.(11)
  | "x4" -> t.(12)
  | "y4" -> t.(13)
  | "z4" -> t.(14)
  | _ -> Util.not_implemented "Multipole"



let cutoff = integrals_cutoff

let to_powers x =
  let open Zkey in
  match to_powers x with
  | Six x -> x
  | _ -> assert false

(** Computes all the integrals of the contracted shell pair *)
let contracted_class shell_a shell_b : float Zmap.t array =

  match Csp.make shell_a shell_b with
  | None -> Array.init 15 (fun _ -> Zmap.create 0)
  | Some shell_p ->
    begin

      (* Pre-computation of integral class indices *)
      let class_indices = Csp.zkey_array shell_p in

      let contracted_class =
        Array.init 15 (fun _ -> Array.make (Array.length class_indices) 0.)
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
              and xa = Co.(get X) @@ Cs.center shell_a
              and ya = Co.(get Y) @@ Cs.center shell_a
              and za = Co.(get Z) @@ Cs.center shell_a
              in

              Array.iteri (fun i key ->
                  let (angMomA, angMomB) = to_powers key in
                  (* 1D Overlap <i|j> *)
                  let f k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b, Co.get xyz center_pa)
                  in
                  (* 1D <i|x-Xa|j> *)
                  let g k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA + 1, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b, Co.get xyz center_pa)
                  in
                  (* 1D <i|(x-Xa)^2|j> *)
                  let h k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA + 2, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b, Co.get xyz center_pa)
                  
                   in
                  (* 1D <i|(x-Xa)^3|j> *)
                  let j k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA + 3, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b, Co.get xyz center_pa)
                   in
                  (* 1D <i|(x-Xa)^4|j> *)
                  let l k =
                    let xyz = xyz_of_int k in
                    Overlap_primitives.hvrr (Po.get xyz angMomA + 4, Po.get xyz angMomB)
                      expo_inv
                      (Co.get xyz a_minus_b, Co.get xyz center_pa)
                   
                  in
                  let norm =  norm_coef_scales.(i) in
                  let f0, f1, f2, g0, g1, g2, h0, h1, h2, j0, j1, j2 , l0, l1, l2 =
                    f 0, f 1, f 2, g 0, g 1, g 2, h 0, h 1, h 2, j 0, j 1, j 2, l 0, l 1, l 2
                  in
                  let  x = g0 +. f0 *. xa in
                  let  y = g1 +. f1 *. ya in
                  let  z = g2 +. f2 *. za in
                  let x2 = h0 +. xa *. (2. *. x -. xa *. f0) in
                  let y2 = h1 +. ya *. (2. *. y -. ya *. f1) in
                  let z2 = h2 +. za *. (2. *. z -. za *. f2) in
                  let x3 = j0 +. xa *. f0 *. (3. *. x2 -. 3. *. x  *. xa +. xa *. xa) in
                  let y3 = j1 +. ya *. f1 *. (3. *. y2 -. 3. *. y  *. ya +. ya *. ya) in
                  let z3 = j2 +. za *. f2 *. (3. *. z2 -. 3. *. z  *. za +. za *. za) in
                  let x4 = l0 +. xa *. f0 *. ( 4. *. x3 -. 6. *. x2 *. xa +. 4. *. x *. xa *. xa -. xa *. xa *. xa) in
                  let y4 = l1 +. ya *. f1 *. ( 4. *. y3 -. 6. *. y2 *. ya +. 4. *. y *. ya *. ya -. ya *. ya *. ya) in
                  let z4 = l2 +. za *. f2 *. ( 4. *. z3 -. 6. *. z2 *. za +. 4. *. z *. za *. za -. za *. za *. za) in

                  let c = contracted_class in
                  let d = coef_prod *. norm in
                  c.(0).(i) <- c.(0).(i) +. d *.  x *. f1 *. f2;
                  c.(1).(i) <- c.(1).(i) +. d *. f0 *.  y *. f2;
                  c.(2).(i) <- c.(2).(i) +. d *. f0 *. f1 *.  z;
                  c.(3).(i) <- c.(3).(i) +. d *. x2 *. f1 *. f2;
                  c.(4).(i) <- c.(4).(i) +. d *. f0 *. y2 *. f2;
                  c.(5).(i) <- c.(5).(i) +. d *. f0 *. f1 *. z2;
                  c.(6).(i) <- c.(6).(i) +. d *.  x *.  y *. f2;
                  c.(7).(i) <- c.(7).(i) +. d *. f0 *.  y *.  z;
                  c.(8).(i) <- c.(8).(i) +. d *.  x *. f1 *.  z;
                  c.(9).(i) <- c.(9).(i) +. d *.  x3 *.  f1 *. f2;
                  c.(10).(i) <- c.(10).(i) +. d *. f0 *. y3 *. f2;
                  c.(11).(i) <- c.(11).(i) +. d *. f0 *. f1 *. z3;
                  c.(12).(i) <- c.(12).(i) +. d *. x4 *. f1 *. f2;
                  c.(13).(i) <- c.(13).(i) +. d *. f0 *. y4 *. f2;
                  c.(14).(i) <- c.(14).(i) +. d *. f0 *. f1 *. z4;

                ) class_indices
            end
        ) (Csp.coefs_and_shell_pairs shell_p);
      let result =
        Array.map (fun c -> Zmap.create (Array.length c) ) contracted_class
      in
      for j=0 to Array.length result -1 do
        let rj = result.(j) in
        let cj = contracted_class.(j) in
        Array.iteri (fun i key -> Zmap.add rj key cj.(i)) class_indices
      done;
      result
    end


(** Create multipole matrices *)
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

  let result = Array.init 15 (fun _ -> Matrix.create n n |> Matrix.to_bigarray_inplace) in
  for j=0 to (Array.length shell) - 1 do
    for i=0 to j do
      (* Compute all the integrals of the class *)
      let cls =
        contracted_class shell.(i) shell.(j)
      in

      for k=0 to 14 do
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
                  try Zmap.find cls.(k) key
                  with Not_found -> 0.
                in
                result.(k).{i_c,j_c} <- value;
                result.(k).{j_c,i_c} <- value;
              ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(i))))
          ) (Am.zkey_array (Singlet (Cs.ang_mom shell.(j))))
      done;
    done;
  done;
  let result = 
    Array.map Matrix.of_bigarray_inplace result
  in
  Array.iter Matrix.detri_inplace result;
  result


let to_file ~filename eni_array =
  let n = Matrix.dim1 eni_array in
  let eni_array = Matrix.to_bigarray_inplace eni_array in
  let oc = open_out filename in
    
  for j=1 to n do
    for i=1 to j do
      let value = eni_array.{i,j} in
      if (value <> 0.) then
        Printf.fprintf oc " %5d %5d %20.15f\n" i j value;
    done;
  done;
  close_out oc
    

