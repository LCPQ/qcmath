open Common
open Linear_algebra
open Gaussian

module Am  = Angular_momentum
module Bs  = Basis
module Cs  = Contracted_shell
module Ov  = Overlap

type t = (Bs.t, Bs.t) Matrix.t


  
let make_canonical ~thresh ~basis ~cartesian ~overlap =

  let overlap_matrix =  overlap in

  let make_canonical_spherical basis =
    let ao_num = Bs.size basis in
    let cart_sphe : (Bs.t, Bs.t) Matrix.t = Matrix.make ao_num ao_num 0. 
    and i = ref 0 
    and n = ref 0 in
    Array.iter (fun shell ->
      let submatrix =
          Spherical_to_cartesian.matrix (Cs.ang_mom shell)
          |> Matrix.relabel 
        in
        Matrix.copy_inplace ~b:cart_sphe ~br:(!i+1) ~bc:(!n+1) submatrix;
        i := !i + Matrix.dim1 submatrix;
        n := !n + Matrix.dim2 submatrix;
      ) (Bs.contracted_shells basis);
    let s = Matrix.gemm_tn ~m:!n cart_sphe overlap_matrix in
    let overlap_matrix = Matrix.gemm_nn s ~n:!n cart_sphe in
    let s = Orthonormalization.canonical_ortho ~thresh ~overlap:overlap_matrix (Matrix.identity !n) in
    Matrix.gemm_nn cart_sphe ~k:!n s
  in

  if cartesian then
    Orthonormalization.canonical_ortho ~thresh ~overlap:overlap_matrix (Matrix.identity @@ Matrix.dim1 overlap_matrix)
  else
    match basis with
    | None -> invalid_arg
              "Basis.t is required when cartesian=false in make_canonical"
    | Some basis -> make_canonical_spherical basis



let make_lowdin ~thresh ~overlap =
  
  let u_vec, u_val =
    Matrix.diagonalize_symm overlap
  in

  Vector.iter (fun x -> if x < thresh then
    invalid_arg (__FILE__^": make_lowdin") ) u_val;

  let u_val = Vector.reci (Vector.sqrt u_val) in

  let u_vec' =
    Matrix.init_cols (Matrix.dim1 u_vec) (Matrix.dim2 u_vec)
      (fun i j -> u_vec%:(i,j) *. (u_val%.(j)) )
  in
  Matrix.gemm_nt u_vec' u_vec



let make ?(thresh=1.e-12) ?basis ~cartesian overlap =
  (*
  make_lowdin ~thresh ~overlap
  *)
  make_canonical ~thresh ~basis ~cartesian ~overlap

