(* [[file:~/QCaml/ao/basis_gaussian.org::*Type][Type:2]] *)
open Linear_algebra
open Gaussian
open Gaussian_integrals
open Operators
  
module Basis = Gaussian.Basis

type t =
{
  basis              :  Basis.t                     ;
  overlap            :  Overlap.t             lazy_t;
  multipole          :  Multipole.t           lazy_t;
  ortho              :  Orthonormalization.t  lazy_t;
  eN_ints            :  Electron_nucleus.t    lazy_t;
  kin_ints           :  Kinetic.t             lazy_t;
  ee_ints            :  Eri.t                 lazy_t;
  ee_lr_ints         :  Eri_long_range.t      lazy_t;
  f12_ints           :  F12.t                 lazy_t;
  f12_over_r12_ints  :  Screened_eri.t        lazy_t;
  cartesian          :  bool ;
}
(* Type:2 ends here *)



(* |---------------------+--------------------------------------------------|
 * | ~basis~             | One-electron basis set                           |
 * | ~cartesian~         | If true, use cartesian Gaussians (6d, 10f, ...)  |
 * | ~ee_ints~           | Electron-electron potential integrals            |
 * | ~ee_lr_ints~        | Electron-electron long-range potential integrals |
 * | ~eN_ints~           | Electron-nucleus potential integrals             |
 * | ~f12_ints~          | Electron-electron potential integrals            |
 * | ~f12_over_r12_ints~ | Electron-electron potential integrals            |
 * | ~kin_ints~          | Kinetic energy integrals                         |
 * | ~multipole~         | Multipole matrices                               |
 * | ~ortho~             | Orthonormalization matrix of the overlap         |
 * | ~overlap~           | Overlap matrix                                   |
 * | ~size~              | Number of atomic orbitals                        |
 * |---------------------+--------------------------------------------------| *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Access][Access:2]] *)
let basis        t = t.basis
let cartesian    t = t.cartesian
let ee_ints      t = Lazy.force t.ee_ints
let ee_lr_ints   t = Lazy.force t.ee_lr_ints
let eN_ints      t = Lazy.force t.eN_ints
let f12_ints     t = Lazy.force t.f12_ints
let f12_over_r12_ints t = Lazy.force t.f12_over_r12_ints
let kin_ints     t = Lazy.force t.kin_ints
let multipole    t = Lazy.force t.multipole
let ortho        t = Lazy.force t.ortho
let overlap      t = Lazy.force t.overlap
let size         t = Matrix.dim1 (Lazy.force t.overlap)
(* Access:2 ends here *)



(* |----------+--------------------------------------------------------------|
 * | ~values~ | Returns the values of all the AOs evaluated at a given point |
 * |----------+--------------------------------------------------------------| *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Computation][Computation:2]] *)
module Cs = Contracted_shell

let values t point =
  let result = Vector.create (Basis.size t.basis) in
  let resultx = Vector.to_bigarray_inplace result in
  Array.iter (fun shell ->
      Cs.values shell point
      |> Array.iteri
           (fun i_c value ->
             let i = Cs.index shell + i_c + 1 in
             resultx.{i} <- value)
    ) (Basis.contracted_shells t.basis);
  result
(* Computation:2 ends here *)


   
(*    Creates the data structure for atomic orbitals from a Gaussian basis and the
 *    molecular geometry ~Nuclei.t~.
 * 
 *    Defaults:
 *    - ~operators~ : ~[]~
 *    - ~cartesian~ : ~false~
 * 
 *    Example:
 *    #+begin_example
 * let b = Ao.Basis_gaussian.make ~basis nuclei ;;
 * val b : Ao.Basis_gaussian.t = Gaussian Basis, spherical, 15 AOs
 *    #+end_example *)


(* [[file:~/QCaml/ao/basis_gaussian.org::*Creation][Creation:2]] *)
let make ~basis ?(operators=[]) ?(cartesian=false) nuclei =
  
  let overlap = lazy (
    Overlap.of_basis basis
  ) in
  
  let ortho = lazy (
    Lazy.force overlap
    |> Orthonormalization.make ~cartesian ~basis 
  ) in
  
  let eN_ints  = lazy (
    Electron_nucleus.of_basis_nuclei ~basis nuclei
  ) in
  
  let kin_ints = lazy (
    Kinetic.of_basis basis
  ) in
  
  let ee_ints  = lazy (
    Eri.of_basis basis
  ) in
  
  let rec get_f12 = function
    | (Operator.F12 _ as f) :: _ -> f
    | [] -> failwith "Missing F12 operator"
    | _ :: rest -> get_f12 rest
  in

  let rec get_rs = function
    | (Operator.Range_sep _ as r) :: _ -> r
    | [] -> failwith "Missing range-separation operator"
    | _ :: rest -> get_rs rest
  in

  let ee_lr_ints  = lazy (
    Eri_long_range.of_basis basis~operator:(get_rs operators)
  ) in
  
  let f12_ints = lazy (
    F12.of_basis basis ~operator:(get_f12 operators)
  ) in
  
  let f12_over_r12_ints = lazy (
    Screened_eri.of_basis basis ~operator:(get_f12 operators)
  ) in

  let multipole = lazy (
        Multipole.of_basis basis
      ) in

  { basis ; overlap ; multipole ; ortho ; eN_ints ; kin_ints ; ee_ints ;
    ee_lr_ints ; f12_ints ; f12_over_r12_ints ; cartesian }
(* Creation:2 ends here *)

(* [[file:~/QCaml/ao/basis_gaussian.org::*Printers][Printers:2]] *)
let pp ppf t =
  let cart = if t.cartesian then "cartesian" else "spherical" in
  let nao = size t in
  Format.fprintf ppf "@[@[Gaussian Basis@], @[%s@], @[%d AOs@]@]"
    cart nao
(* Printers:2 ends here *)
