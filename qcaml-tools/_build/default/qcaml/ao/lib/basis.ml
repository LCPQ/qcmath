(* [[file:~/QCaml/ao/basis.org::*Types][Types:2]] *)
type t =
  { ao_basis : Basis_poly.t  ;
    cartesian : bool
  }

type ao = Ao_dim.t

open Linear_algebra
open Common
(* Types:2 ends here *)



(*    |--------------------------------+------------------------------------------------------------------------------------------------------------------------|
 *    | ~of_nuclei_and_basis_filename~ | Creates the data structure for the atomic orbitals basis from a molecule ~Nuclei.t~ and the name of the basis-set file |
 *    |--------------------------------+------------------------------------------------------------------------------------------------------------------------|
 * 
 *    Defaults:
 *    - ~kind~ : ~`Gaussian~
 *    - ~operators~ : ~[]~
 *    - ~cartesian~ : ~false~
 * 
 *    Example:
 *    #+begin_example
 * let b = Ao.Basis.of_nuclei_and_basis_filename ~nuclei filename;;
 * val b : Ao.Basis.t = Gaussian Basis, spherical, 15 AOs
 *    #+end_example *)
   

(* [[file:~/QCaml/ao/basis.org::*Conversions][Conversions:2]] *)
let of_nuclei_and_basis_filename ?(kind=`Gaussian) ?operators ?(cartesian=false)
    ~nuclei filename =
  match kind with
  | `Gaussian ->
      let basis =
        Gaussian.Basis.of_nuclei_and_basis_filename  ~nuclei filename
      in
      let ao_basis = 
        Basis_poly.Gaussian (Basis_gaussian.make ~basis ?operators ~cartesian nuclei )
      in
      { ao_basis ; cartesian }
  | _ -> failwith "of_nuclei_and_basis_filename needs to be called with `Gaussian"
(* Conversions:2 ends here *)



(* |---------------------+--------------------------------------------------|
 * | ~size~              | Number of atomic orbitals in the AO basis set    |
 * | ~ao_basis~          | One-electron basis set                           |
 * | ~overlap~           | Overlap matrix                                   |
 * | ~multipole~         | Multipole matrices                               |
 * | ~ortho~             | Orthonormalization matrix of the overlap         |
 * | ~eN_ints~           | Electron-nucleus potential integrals             |
 * | ~kin_ints~          | Kinetic energy integrals                         |
 * | ~ee_ints~           | Electron-electron potential integrals            |
 * | ~ee_lr_ints~        | Electron-electron long-range potential integrals |
 * | ~f12_ints~          | Electron-electron potential integrals            |
 * | ~f12_over_r12_ints~ | Electron-electron potential integrals            |
 * | ~cartesian~         | If true, use cartesian Gaussians (6d, 10f, ...)  |
 * | ~values~            | Values of the AOs evaluated at a given point     |
 * |---------------------+--------------------------------------------------| *)



(* [[file:~/QCaml/ao/basis.org::*Access][Access:2]] *)
let not_implemented () =
  Util.not_implemented "Only Gaussian is implemented"
  
let ao_basis t = t.ao_basis
                    
let size t = 
  match t.ao_basis with
  | Basis_poly.Gaussian b -> Basis_gaussian.size b
  | _ -> not_implemented ()

let overlap t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.overlap b
    | _ -> not_implemented ()
  end
  |> Matrix.relabel
       
let multipole t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b ->
        let m = Basis_gaussian.multipole b in
        fun s ->
          Gaussian_integrals.Multipole.matrix m s
          |> Matrix.relabel
    | _ -> not_implemented ()
  end
       
let ortho t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.ortho b
    | _ -> not_implemented ()
  end
  |> Matrix.relabel
       
let eN_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.eN_ints b
    | _ -> not_implemented ()
  end
  |> Matrix.relabel
       
let kin_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.kin_ints b
    | _ -> not_implemented ()
  end
  |> Matrix.relabel
       
let ee_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.ee_ints b
    | _ -> not_implemented ()
  end
  |> Four_idx_storage.relabel
       
let ee_lr_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.ee_lr_ints b
    | _ -> not_implemented ()
  end
  |> Four_idx_storage.relabel
       
let f12_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.f12_ints b
    | _ -> not_implemented ()
  end
  |> Four_idx_storage.relabel
       
let f12_over_r12_ints t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.f12_over_r12_ints b
    | _ -> not_implemented ()
  end
  |> Four_idx_storage.relabel
       
let cartesian t = t.cartesian
                    

let values t point =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.values b point
    | _ -> not_implemented ()
  end
  |> Vector.relabel
(* Access:2 ends here *)

(* [[file:~/QCaml/ao/basis.org::*Printers][Printers:2]] *)
let pp ppf t =
  begin
    match t.ao_basis with
    | Basis_poly.Gaussian b -> Basis_gaussian.pp ppf b
    | _ -> not_implemented ()
  end
(* Printers:2 ends here *)
