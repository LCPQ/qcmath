(* Tests *)


(* [[file:~/QCaml/particles/nuclei.org::*Tests][Tests:1]] *)
open Common
open Particles
open Alcotest

let wd = Common.Qcaml.root ^ Filename.dir_sep ^ "test"

let test_xyz molecule length repulsion charge core =
  let xyz = Nuclei.of_xyz_file (wd^Filename.dir_sep^molecule^".xyz") in
  check int "length" length (Array.length xyz);
  check (float 1.e-4) "repulsion" repulsion (Nuclei.repulsion xyz);
  check int "charge" charge (Charge.to_int @@ Nuclei.charge xyz);
  check int "small_core" core (Nuclei.small_core xyz);
  ()

let tests = [
  "caffeine", `Quick, (fun () -> test_xyz "caffeine" 24 917.0684 102 28);
  "water",    `Quick, (fun () -> test_xyz "water"     3  9.19497  10  2);
]
(* Tests:1 ends here *)
