(* Tests *)


(* [[file:~/QCaml/perturbation/mp2.org::*Tests][Tests:1]] *)
open Alcotest
open Particles
    
let wd = Common.Qcaml.root ^ Filename.dir_sep ^ "test"

let tests = 
  [ "HF Water", `Quick, fun () -> 
      let nuclei =
        wd ^ Filename.dir_sep ^ "water.xyz"
        |> Nuclei.of_xyz_file 
      in
      let basis_filename =
        wd ^ Filename.dir_sep ^ "cc-pvdz"
      in
      let ao_basis = 
        Ao.Basis.of_nuclei_and_basis_filename ~kind:`Gaussian
          ~cartesian:false ~nuclei basis_filename
      in

      let simulation = Simulation.make ~nuclei ao_basis in

      let hf = Mo.Hartree_fock.make ~guess:`Huckel simulation in
      Format.printf "%a" (Mo.Hartree_fock.pp) hf;
      check (float 2.e-10) "Energy" (-76.0267987005) (Mo.Hartree_fock.energy hf);

      let mo_basis = Mo.Basis.of_hartree_fock hf in

      let frozen_core = Mo.Frozen_core.(make Small nuclei) in

      let mp2 = Perturbation.Mp2.make ~frozen_core mo_basis in

      let e_mp2 = Perturbation.Mp2.energy mp2 in

      check (float 1.e-9) "MP2" (-0.2016211415) (e_mp2)
  ]
(* Tests:1 ends here *)
