(*
   Run all the OCaml test suites defined in the project.
*)

let test_suites: unit Alcotest.test list = [
  "Common.Bitstring", Test_common.Bitstring.tests;
  "Common.Util", Test_common.Util.tests;
  "Linear_algebra.Vector", Test_linear_algebra.Vector.tests;
  "Particles.Nuclei", Test_particles.Nuclei.tests;
  "Particles.Electrons", Test_particles.Electrons.tests;
  "Gaussian_basis.General_basis", Test_gaussian.General_basis.tests;
  "Ao_basis.Ao_basis_gaussian", Test_ao.Ao_basis_gaussian.tests;
  "Ao_basis.Ao_basis", Test_ao.Ao_basis.tests;
  "Mo.Guess", Test_mo.Guess.tests;
  "Mo.Hartree_Fock", Test_mo.Hf.tests;
  "Perturbation.Mp2", Test_perturbation.Mp2.tests;
]

let () = Alcotest.run "QCaml" test_suites
