open Alcotest
open Particles
open Operators
open Mo.Guess
open Linear_algebra
    
let wd = Common.Qcaml.root ^ Filename.dir_sep ^ "test"

let test_case ao_basis =

  let test_hcore () =
    match make ~guess:`Hcore ao_basis with
    | Hcore matrix -> 
      let a = Matrix.to_array matrix in
      let reference =
        Matrix.add 
          (Ao.Basis.eN_ints  ao_basis)
          (Ao.Basis.kin_ints ao_basis)
        |> Matrix.to_array
      in
      Array.iteri (fun i x ->
        let message =
          Printf.sprintf "Guess line %d" (i)
        in
        check (array (float 1.e-15)) message a.(i) x) reference
    | _ -> assert false
  
  in
  [
    "HCore", `Quick, test_hcore;
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
    test_case ao_basis ;
  ]
    
