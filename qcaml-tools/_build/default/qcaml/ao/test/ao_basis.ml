open Alcotest
open Particles
open Operators
open Linear_algebra
open Ao.Basis

let wd = Common.Qcaml.root ^ Filename.dir_sep ^ "test"
 
let make_tests name t =

  let check_matrix title a r =
    let ax =
      Matrix.as_vec_inplace a
      |> Vector.to_bigarray_inplace
    in
    Matrix.as_vec_inplace r
    |> Vector.iteri (fun i x ->
          let message =
            Printf.sprintf "%s line %d" title i
          in
          check (float 1.e-10) message ax.{i} x
        ) 
  in

  let check_eri a r =
    let f { Four_idx_storage.i_r1 ; j_r2 ; k_r1 ; l_r2 ; value } =
      (i_r1, (j_r2, (k_r1, (l_r2, value))))
    in
    let a = Four_idx_storage.to_list a |> List.rev_map f in
    let r = Four_idx_storage.to_list r |> List.rev_map f in
    check (list (pair int (pair int (pair int (pair int (float 1.e-10)))))) "ERI" a r
  in

  let test_overlap () =
    let reference =
      Matrix.sym_of_file (wd ^ Filename.dir_sep ^ name ^ "_overlap.ref")
    in
    check_matrix "Overlap" (overlap t) reference
  in

  let test_eN_ints () =
    let reference =
      Matrix.sym_of_file (wd ^ Filename.dir_sep ^ name ^ "_nuc.ref")
    in
    check_matrix "eN_ints" (eN_ints t) reference
  in

  let test_kin_ints () =
    let reference =
      Matrix.sym_of_file (wd ^ Filename.dir_sep ^ name ^  "_kin.ref")
    in
    check_matrix "kin_ints" (kin_ints t) reference
  in

  let test_ee_ints () =
    let reference =
      Four_idx_storage.of_file (wd ^ Filename.dir_sep ^ name ^ "_eri.ref")
        ~sparsity:`Dense ~size:(size t)
    in
    check_eri (ee_ints t) reference
    ;
  in

  let test_ee_lr_ints () =
    let reference =
      Four_idx_storage.of_file (wd ^ Filename.dir_sep ^ name ^ "_eri_lr.ref")
        ~sparsity:`Dense ~size:(size t)
    in
    check_eri (ee_lr_ints t) reference
  in

  [
    "Overlap",     `Quick,  test_overlap;
    "eN_ints",     `Quick,  test_eN_ints;
    "kin_ints",    `Quick,  test_kin_ints;
    "ee_ints",     `Quick,  test_ee_ints;
    "ee_lr_ints",  `Quick,  test_ee_lr_ints;
  ]
  
let tests =
  List.concat [ 
    let nuclei =
      wd ^ Filename.dir_sep ^ "water.xyz"
    |> Nuclei.of_xyz_file 
    in
    let basis_filename =
      wd ^ Filename.dir_sep ^ "cc-pvdz"
    in
    let rs = 0.5 in
    let operators = [ Operator.of_range_separation rs ] in
    let ao_basis = 
      Ao.Basis.of_nuclei_and_basis_filename ~kind:`Gaussian
        ~operators ~cartesian:false ~nuclei basis_filename
    in
    make_tests "water" ao_basis ;

  ]
    
