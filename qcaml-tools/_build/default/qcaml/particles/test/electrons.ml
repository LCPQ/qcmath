(* [[file:~/QCaml/particles/electrons.org::*Type][Type:3]] *)
open Common
open Particles
open Alcotest

let test_all () =
  let nuclei =
"3
Water
O       0.                     0.   0.
H      -0.756950272703377558   0.  -0.585882234512562827
H       0.756950272703377558   0.  -0.585882234512562827
"
  |> Nuclei.of_xyz_string 
  in
  let e = Electrons.of_atoms nuclei in
(* Type:3 ends here *)

(* [[file:~/QCaml/particles/electrons.org::*Creation][Creation:3]] *)
check int "of_atoms alfa" 5 (Electrons.n_alfa e);
check int "of_atoms beta" 5 (Electrons.n_beta e);
(* Creation:3 ends here *)

(* [[file:~/QCaml/particles/electrons.org::*Access][Access:3]] *)
check int "charge " (-10) (Charge.to_int @@ Electrons.charge e);
check int "n_elec" 10 (Electrons.n_elec e);
check int "multiplicity" 1 (Electrons.multiplicity e);
check int "of_atoms alfa m3" 6 (Electrons.(of_atoms ~multiplicity:3 nuclei |> n_alfa));
check int "of_atoms beta m3" 4 (Electrons.(of_atoms ~multiplicity:3 nuclei |> n_beta));
check int "of_atoms n_elec m3" 10 (Electrons.(of_atoms ~multiplicity:3 nuclei |> n_elec));
check int "of_atoms alfa m2 c1" 5 (Electrons.(of_atoms ~multiplicity:2 ~charge:1 nuclei |> n_alfa));
check int "of_atoms beta m2 c1" 4 (Electrons.(of_atoms ~multiplicity:2 ~charge:1 nuclei |> n_beta));
check int "of_atoms beta m2 c1" 9 (Electrons.(of_atoms ~multiplicity:2 ~charge:1 nuclei |> n_elec));
check int "of_atoms mult m2 c1" 2 (Electrons.(of_atoms ~multiplicity:2 ~charge:1 nuclei |> multiplicity));
check bool "make" true (Electrons.make 6 4 = Electrons.(of_atoms ~multiplicity:3 nuclei));
(* Access:3 ends here *)

(* Tests *)


(* [[file:~/QCaml/particles/electrons.org::*Tests][Tests:1]] *)
  ()

let tests = [
  "all", `Quick, test_all
]
(* Tests:1 ends here *)
